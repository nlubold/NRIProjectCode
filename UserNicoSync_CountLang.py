import pandas as pd
from datetime import datetime
import string



# loop through user
# if row time equals row time in nico, then insert both
# if nico is > then, then just insert user
# if nico is < then, then just insert nico
# if error == insert error
# if audio == insert audio
# with insertion, first column is DateTime, second column UserID, third is SessionID, ProblemID, StepID [1-5]
# then user values: DialogueAct, DialogueActConfidence, Spoke, StepAnswerKey, ClickStep, transcript [6 - 11]
# then nico values: NicoMovement, AnswerKey, AnsweredStep, NicoResponse [6 - 9]
# audio values: AudioKey, UserID, DateTime, FilePathAudio, ProblemID, StepID, SessionID, Prosody_Pitch
# error values: LogKey, DateTime, UserID, ProblemID, StepID, SessionID, ErrorCode, ErrorMessage, FormName, StackTrace

inclusive = {"we":0, "our":0,"great":0, "nice":0, "good":0, "cool":0,"hello":0,"thank":0,"welcome":0,"Nico":0}
keep = string.lowercase + string.digits + string.whitespace
table = string.maketrans(keep, keep)
delete = ''.join(set(string.printable) - set(keep))

def incrementLanguageCounts(transcript):
    for key, val in inclusive.iteritems():
        transcript = str(transcript).replace("\'", " ")
        numOccur = str(transcript).lower().translate(table, delete).split().count(key)
        inclusive[key] += numOccur

def writeCounts(userID):
    line1 = "\n ID"
    line2 = "\n" + userID
    for key, val in inclusive.iteritems():
        line1 = line1 + "," + key
        line2 = line2 + "," + str(inclusive[key])
        inclusive[key] = 0
    with open("C:\\Nikki\\ASU_Research\\NRI_Project\\Data\\Pilots\\LanguageCounts_14.csv", "a") as myfile:
        myfile.write(line1)
        myfile.write(line2)

def writeUserData(alldata, user, userIndex, alldataIndex, lastUser):
    alldata.loc[alldataIndex]["DateTime"] = user.iloc[userIndex]["DateTime"]
    alldata.loc[alldataIndex]["UserID"] = user.iloc[userIndex]["UserID"]
    alldata.loc[alldataIndex]["SessionID"] = user.iloc[userIndex]["SessionID"]
    alldata.loc[alldataIndex]["ProblemID"] = user.iloc[userIndex]["ProblemID"]
    alldata.loc[alldataIndex]["StepID"] = user.iloc[userIndex]["StepID"]
    alldata.loc[alldataIndex]["Owner"] = "user"
    alldata.loc[alldataIndex]["DialogueAct"] = user.iloc[userIndex]["DialogueAct"]
    alldata.loc[alldataIndex]["DialogueActConfidence"] = user.iloc[userIndex]["DialogueActConfidence"]
    alldata.loc[alldataIndex]["Spoke"] = user.iloc[userIndex]["Spoke"]
    alldata.loc[alldataIndex]["StepAnswer"] = user.iloc[userIndex]["StepAnswer"]
    alldata.loc[alldataIndex]["ClickStep"] = user.iloc[userIndex]["ClickStep"]
    alldata.loc[alldataIndex]["Transcript"] = user.iloc[userIndex]["transcript"]

    # Increment special language usage counts & write out to file if new user
    thisUser = user.iloc[userIndex]['UserID']
    userTrans = user.iloc[userIndex]["transcript"]

    if lastUser == "":
        lastUser = thisUser

    if thisUser == lastUser:
        incrementLanguageCounts(userTrans)
    else:
        writeCounts(lastUser)
        incrementLanguageCounts(userTrans)

    return alldata


def writeNicoData(alldata, nico, nicoIndex, alldataIndex):
    alldata.loc[alldataIndex]["DateTime"] = nico.iloc[nicoIndex]["DateTime"]
    alldata.loc[alldataIndex]["UserID"] = nico.iloc[nicoIndex]["UserID"]
    alldata.loc[alldataIndex]["SessionID"] = nico.iloc[nicoIndex]["SessionID"]
    alldata.loc[alldataIndex]["ProblemID"] = nico.iloc[nicoIndex]["ProblemID"]
    alldata.loc[alldataIndex]["StepID"] = nico.iloc[nicoIndex]["StepID"]
    alldata.loc[alldataIndex]["Owner"] = "nico"
    alldata.loc[alldataIndex]["NicoMovement"] = nico.iloc[nicoIndex]["NicoMovement"]
    alldata.loc[alldataIndex]["Answered"] = nico.iloc[nicoIndex]["Answered"]
    alldata.iloc[alldataIndex]["Transcript"] = nico.loc[nicoIndex]["NicoResponse"]

    return alldata

def syncLogs(userFile, nicoFile, errorFile, audioFile):
    user = pd.read_csv(userFile, names=["StateKey","UserID","DateTime","SessionID","ProblemID","StepID","DialogueAct","DialogueActConfidence","Spoke","StepAnswer","ClickStep","NumAuto","transcript"],infer_datetime_format=True)
    nico = pd.read_csv(nicoFile, names=["NicoState","UserID","DateTime","SessionID","ProblemID","StepID","NicoMovement","AnswerKey","Answered","NicoResponse","FilePath"])
    #error = pd.read_csv(errorFile)
    #audio = pd.read_csv(audioFile)

    userRows = user.shape[0]
    nicoRows = nico.shape[0]

    alldata = pd.DataFrame(index=range(0, (userRows + nicoRows)), columns = ["UserID","DateTime","SessionID","ProblemID","StepID","Owner","DialogueAct","DialogueActConfidence","Spoke","StepAnswer","ClickStep","NicoMovement","Answered","Transcript"])

    alldataIndex = 0
    userIndex = 0
    nicoIndex = 0
    trustNicoData = True
    trustUserData = True
    lastUser = ""

    while userIndex < userRows or nicoIndex < nicoRows:


        if userIndex < userRows:
            userDateTime = datetime.strptime(user.iloc[userIndex]['DateTime'],'%m/%d/%y %H:%M')
        else:
            trustUserData = False
        if nicoIndex < nicoRows:
            nicoDateTime = datetime.strptime(nico.iloc[nicoIndex]['DateTime'],'%m/%d/%y %H:%M')
        else:
            trustNicoData = False

        if userDateTime == nicoDateTime and trustUserData and trustNicoData:
            alldata = writeUserData(alldata,user,userIndex, alldataIndex, lastUser)
            lastUser = user.iloc[userIndex]['UserID']
            userIndex += 1
            alldataIndex += 1

            alldata = writeNicoData(alldata,nico,nicoIndex,alldataIndex)
            nicoIndex += 1
            alldataIndex += 1

        elif userDateTime < nicoDateTime and trustUserData and trustNicoData:
            alldata = writeUserData(alldata,user,userIndex, alldataIndex, lastUser)
            lastUser = user.iloc[userIndex]['UserID']
            userIndex += 1
            alldataIndex += 1

        elif userDateTime > nicoDateTime and trustUserData and trustNicoData:
            alldata = writeNicoData(alldata, nico, nicoIndex, alldataIndex)
            nicoIndex += 1
            alldataIndex += 1

        elif not trustNicoData:
            alldata = writeUserData(alldata, user, userIndex, alldataIndex, lastUser)
            lastUser = user.iloc[userIndex]['UserID']
            userIndex += 1
            alldataIndex += 1

        elif not trustUserData:
            alldata = writeNicoData(alldata, nico, nicoIndex, alldataIndex)
            nicoIndex += 1
            alldataIndex += 1

        else:
            print "ERROR: User and Nico DateTime fields cannot be compared"

    writeCounts(lastUser)
    alldata.to_csv("C:\\Nikki\\ASU_Research\\NRI_Project\\System\\NRI_Git_Hub\\automated_system\\LogSync\\data\\ID14.csv",columns = ["UserID","DateTime","SessionID","ProblemID","StepID","Owner","DialogueAct","DialogueActConfidence","Spoke","StepAnswer","ClickStep","NicoMovement","Answered","Transcript"])

def main():
    '''
    if len(sys.argv) != 5:
        print 'usage: ./readfile2.py socialCodes transcriptfileDirectory outputFileNumTurns outputFileWhichTurns'
        sys.exit(1)
    '''

    userFile = "C:\\Nikki\\ASU_Research\\NRI_Project\\System\\NRI_Git_Hub\\automated_system\\LogSync\\data\\userresults.csv"
    nicoFile = "C:\\Nikki\\ASU_Research\\NRI_Project\\System\\NRI_Git_Hub\\automated_system\\LogSync\\data\\nicoresults.csv"
    errorFile = ""
    audioFile = ""
    syncLogs(userFile, nicoFile, errorFile, audioFile)


if __name__ == '__main__': main()