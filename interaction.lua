--Wait half seconds
session:sleep(500)

--get the value set by dialplan into channel
variable_my_channel_variable = session:getVariable("my_channel_variable");
var_call_id_num = session:getVariable("caller_id_number");

--print that value on FreeSWITCH console and logfile
session:consoleLog("info", "dialplan set channel variable value to: ".. variable_my_channel_variable .. "\n");
session:consoleLog("info", "caller-id-number is: ".. var_call_id_num .. "\n");

--prompt the user to enter digits, manage input errors, transfer on final failure
local match_tel
tel_arr = {user1 = "^+?[78]9211111111", user2 = "^+?[78]9311111111", user3 = "^+?[78]9411111111", user4 = "^+?[78]9511111111", user5 = "^+?[78]9611111111", user6 = "^+?[78]9711111111"}
for i,tel in pairs(tel_arr) do
    if (string.match(var_call_id_num, tel)) then
    session:consoleLog("info", "FIO is ".. i .. "\nCatch-number is: ".. tel .. "\n");
    match_tel = tel
    digits = session:playAndGetDigits(3, 12, 1, 8000, "#", "sound/dialtone.wav", "", "", "digits_received");
    break
    end
end

if (not match_tel) then
   session:consoleLog("info", "Caller-id-number is: ".. var_call_id_num  .. "\n");
   digits = session:playAndGetDigits(3, 3, 1, 3000, "#", "sound/dialtone.wav", "", "^([12][0-9][0-9])$", "digits_received");
end

--print gathered digits on FreeSWITCH console and logfile
session:consoleLog("info", "Lua variable digits is: ".. digits .."\n")

if (digits ~= "") then
    session:transfer(digits, "XML", "name_of_dialplan");
else
    session:execute("playback", "sound/sound.wav");
end

--End of script, will automatically hangup
