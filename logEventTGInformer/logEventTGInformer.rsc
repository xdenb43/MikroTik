# logEventTGInformer | by @xdenb43
# Sends log events filtered by condition to speicific topic of telegram group
#
# /!\ tested on hap ax3, RoS 7.17.2+
# /!\ Known issue: parser failes for keyword "HTTP"

# BEGIN SETUP
:local tgBotToken "$TOKEN";
:local tgChatId "$CHATID";
:local tgTopicId "$GROUPTOPICID";
:local tgUrl "https://api.telegram.org/bot$tgBotToken/sendMessage?chat_id=$tgChatId&message_thread_id=$tgTopicId&text=";
:local mikrotId ("\E2\9D\97"." `".[/system identity get name]." ".[/system resource get board-name]."` \E2\9D\97");
:local scheduleName "logEventTGInformer";
:local logsBuffer [:toarray [/log find topics~"(error|critical|netwatch)" || message~"([fF]ailure|router rebooted)"]]
:local ignoreInLog {"static dns entry changed"; "changed script settings"; "HTTP"}
#:local ignoreInLog [:toarray " "]
# Telegram messages can currently hold up to 4KB of text (4096 latin characters).
:local symbolsLimit 4096
# END SETUP

# SCHEDULER
# warn if schedule does not exist and create it
:if ([:len [/system scheduler find name="$scheduleName"]] = 0) do={
    /log warning "[logEventTGInformer] Alert : Schedule does not exist. Creating schedule ...."
    /system scheduler add name=$scheduleName interval=60s start-time=startup on-event=logEventTGInformer policy=read,write,test
    /log warning "[logEventTGInformer] Alert : Schedule created!"
}

# MAIN PART
# for checking time of each log entry
:local currentTime
:local result ""
# get last time from scheduler's comment
:local lastTime [/system scheduler get [find name="$scheduleName"] comment]
:local firstRun false

:if ([:len $logsBuffer] > 0) do={
    :if ([:len $lastTime] = 0) do={
        :set lastTime [:totime [/log get [:pick $logsBuffer 0] time]];
        :set firstRun true
    }

    # loop through all filtered log entries
    :foreach line in=$logsBuffer do={
        :set currentTime [:totime [/log get $line time]]
        :local message [/log get $line message]
        :local tempResult ([/log get $line time]."%0A".$message."%0A%0A")
        :if (( $currentTime > $lastTime) || ($firstRun = true)) do={
            :set firstRun false
            # loop through all ignoreInLog array items
            :local keepLog true
            :foreach j in=$ignoreInLog do={
                # if this log entry contains any of them, it will be ignored
                :if ($message ~ "$j") do={
                    :set keepLog false
                }
            }
            :if ($keepLog = true) do={
                :if (([:len "$mikrotId%0A%0A$result"] + [:len "$tempResult"]) < $symbolsLimit) do={
                    :set result ($result.$tempResult);
                    :set lastTime $currentTime;
                }
            }
        }
    }
}

# if no internet connection then script need to know informer is not sent
if ([:len $result] > 0) do={
    :local fetchResult [/tool fetch url="$tgUrl$mikrotId%0A%0A$result&parse_mode=markdown" keep-result=no as-value];
    :if ($fetchResult->"status" = "finished") do={
        /system scheduler set [find name="$scheduleName"] comment=$lastTime
    }
}
