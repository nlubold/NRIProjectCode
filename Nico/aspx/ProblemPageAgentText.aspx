<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="false" CodeBehind="ProblemPageAgentText.aspx.cs" Inherits="Nico.aspx.ProblemPageAgentText" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">


    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1" />

    <div class="container" id="overalldiv">

       
        <asp:Label ID="ProblemDescription" runat="server" CssClass ="h3"></asp:Label>
        
        <div class="row">
            
            <div id="NicoStuff" class=".col-xs-3 center-block">
                         <br />
                        
                        <img id="NAOButton" style="width:247px; height:262px;position:fixed;top:100px; left:75px;" src="../content/img/imagedirectory/nao-sit.png"/>
                        <br />
            </div>


            
            <div id="ProblemUIStuff" class="col-sm-9">
                <div class="row">
                    <div id="problemText" class="col-sm-12 text-center">
                            <br />
                            <br />
                            <h4 id="probdescr">Help Emma by explaining what to do.</h4> 
                            <br />
                    </div>
                </div>
                <div class="row">
                            <div id="priorsteptouch" class="col-sm-3 text-center" >
                                 <img ID="priorStepButton" style="visibility:hidden;width:75px;height:75px;cursor:pointer;" src="../content/img/imagedirectory/double-up-arrow.jpg"/>
                                 <h4 ID="priorStepText" style="visibility:hidden;">Prior Step</h4>
                            </div>
            
                            <div class="col-sm-6 text-center">
                                    <br />
                                    <table id="table3" class="table table-new"></table>
                            </div>
            
                            <div id="nextsteptouch" class="col-sm-3 text-center">
                                <img ID="nextStepButton" style="visibility:visible;width:75px;height:75px;cursor:pointer;" src="../content/img/imagedirectory/double-down-arrow.jpg" />
                                <h4 ID="nextStepText" style="visibility:visible;">Next Step</h4>
                            </div>
        
               </div>

                <div class="row">
                    <div id="textboxarea" class="col-sm-12 text-center">
                        <br />
                        <h4 id="EnterText">Enter Your Explanation Here:</h4> 
                        <textarea id="explanation" rows="4" class="form-control"></textarea>
                        <br />
                        <h4><button type="button" ID="SubmitExplanation" OnClick="submit_Explanation()" style="color:hsl(0, 0%, 30%);visibility:visible;cursor:pointer;">Submit Explanation</button></h4>
                    </div>
                </div>

                <div class="row">
                    <div id="agentResponse" class="col-sm-12 text-center">
                        <br />
                        <h4 id="agentResponseLabel">Agent Response:</h4> 
                        <textarea id="agentResponseText" rows="4" class="form-control" ></textarea>
                        <br />
                    </div>
                </div>
               
                <div class="row">
                    <div id="NextProbDiv" class=".col-xs-12 center-block">
                        <h4><button type="button" ID="NextProblem" OnClick="Next_Problem()" style="color:hsl(0, 0%, 30%);visibility:hidden;cursor:pointer;">Next Problem</button></h4>
                    </div>
                </div>
            </div>
        </div>
        

         <div>
           <h2>Log</h2>
            <pre id="log"></pre>
        </div>

      


        <br />

    </div>
    <link rel="stylesheet" runat="server" media="screen" href="../content/bootstrap.css" />

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js" type="text/javascript"></script>
    <script src="https://code.jquery.com/jquery-1.9.1.min.js"></script>
    <script src="../js/jquery.signalR-2.0.0.min.js"></script>
    <script src="../js/talk.js"></script>
    <script src="../js/audio.js"></script>  
    <script src="../js/recorder.js"></script>


    <script type="text/javascript">

       

        // Variable for triggering speech if speaker is not responding
        //var timer;

        function submit_Explanation() {
            //clearTimeout(timer);
            var textval = document.getElementById("explanation").value;
            if (textval == "") {
                alert("You didn't enter a response!");
            }
            else {
                responseCallNico(textval);
            }

        }

        


        
        function responseCallNico(text) {
            //clearTimeout(timer);
            var data = new FormData();
            data.append('transcript', text);
            data.append('page_loc', 'ProblemPage');

            $("#thinking").css("display", "block");
            $.ajax({
                url: "../handlers/DialogueEngine.ashx",
                type: 'POST',
                data: data,
                contentType: false,
                processData: false,
                success: function (response) {
                    //window.clearTimeout(timer);
                    //timer = window.setTimeout(function () { responseCallNico("no response"); }, 65000);
                    document.getElementById("agentResponseText").value = response;
                },
                complete: function () {
                    updateTable();
                    $("#thinking").css("display", "none");
                },
                error: function (err) {
                    alert(err.statusText)
                }
            });
        }



        // This function updates the table display
        function updateTable(endSession) {
            if (endSession == "end of session") {
                window.location.replace("../aspx/Default.aspx");
            }
            else {
                
                $.getJSON("../handlers/UpdateTable.ashx", function (data) {

                    // Extract variables from first row
                    var numCols = data[0]["Col1"];
                    var step = data[0]["Col2"];
                    var maxSteps = data[0]["Col3"];
                    var answered = data[0]["Col4"];
                    var cell = data[0]["Col5"];
                    var probtext = data[0]["Col6"];
                    var numRows = data[0]["Col7"];
                    var numStep = parseInt(step, 10);
                    var numCell = parseInt(cell, 10);

                    // Update problem description
                    document.getElementById("problemText").getElementsByTagName("h4")[0].innerHTML = String(probtext);
                                        
                    // Create table
                    var oldTable = document.getElementById('table3');
                    var newTable = oldTable.cloneNode();
                    var counter = 0;
                    var stepString = "Step ";
                    var stepCounter = 1;
                    var rowCounter = 0;
                    var thisRow = 0; 

                    // Create Header
                    var trheader = document.createElement('tr');
                    var thfirst = document.createElement('th');
                    thfirst.appendChild(document.createTextNode("Step"));
                    trheader.appendChild(thfirst);

                    for (var key in data[1]) {
                        if (parseInt(numCols, 10) == counter) {
                            counter = 0;
                            break;
                        }
                        else {
                            var thheader = document.createElement('th');
                            thheader.appendChild(document.createTextNode(data[1][key]));
                            trheader.appendChild(thheader);
                            counter++;
                        }
                        newTable.appendChild(trheader);
                    }
                    
                    // Start at i = 2 because in Json, first row is data, second row is header info so 3rd row (i = 2) actual data
                    for (var i = 2; i < data.length; i++) {
                        var tr = document.createElement('tr');

                        // Check if we're on this step; zoom step to make it obvious what step we're on
                        // *********** VERIFY IF THIS IS WHERE I CAN CHANGE IT IF IT IS maxsteps == numsteps
                        // meaning we're on the first step
                        if (numStep == 1 && maxSteps == numRows && i == 2) {
                            tr.style.transform = 'scale(1.2)';
                            tr.style.fontWeight = '700';
                            tr.style.background = 'rgb(140,245,241)';
                            tr.style.border = '1px solid';
                            tr.style.borderColor = 'rgb(140,245,241)';
                            thisRow = 1;
                            rowCounter++;
                        }
                        else if (numStep == 0 && i == 3) {            
                            tr.style.transform = 'scale(1.2)';
                            tr.style.fontWeight = '700';
                            tr.style.background = 'rgb(140,245,241)';
                            tr.style.border = '1px solid';
                            tr.style.borderColor = 'rgb(140,245,241)';
                            thisRow = 1;
                        }
                        else if (i == numStep + 2 && numStep != 0) {
                            tr.style.transform = 'scale(1.2)';
                            tr.style.fontWeight = '700';
                            tr.style.background = 'rgb(140,245,241)';
                            tr.style.border = '1px solid';
                            tr.style.borderColor = 'rgb(140,245,241)';
                            thisRow = 1;
                        }
                        else {
                            // do nothing
                            thisRow = 0;
                        }

                        // Add step number cell
                        var tdstep = document.createElement('td');
                        var stepText = stepString.concat(rowCounter.toString());
                        tdstep.appendChild(document.createTextNode(stepText));
                        // Check if this row is the step that we're currently on, and modify the format of the cell
                        if (thisRow == 1) {
                            tdstep.style.border = '1px solid';
                            tdstep.style.background = 'rgb(140,245,241)';
                            tdstep.style.borderColor = 'rgb(140,245,241)';
                        }
                        tr.appendChild(tdstep);

                        // Add other cell info
                        for (var key in data[i]) {
                            if (counter == parseInt(numCols, 10)) {
                                counter = 0;
                                break;
                            }
                            else {
                                var td = document.createElement('td');
                                td.appendChild(document.createTextNode(data[i][key]));

                                // Check if this cell contains a 'question mark'; if yes then change formatting of text
                                if (String(data[i][key]).includes("?")) {
                                    if (thisRow != 1) {
                                        td.style.color = 'rgb(0,255,255)';
                                        td.style.fontWeight = 'bold';
                                        td.style.fontSize = 'large';
                                    }
                                    else {
                                        td.style.color = '#FFFFFF';
                                    }
                                }
                                

                                // If this row is the step that we're are currently 'on', then modify formatting of the cell, see if this cell contains the 'answer'
                                // and then modify the 'answer'
                                if (thisRow == 1) {
                                    td.style.border = '1px solid';
                                    td.style.borderColor = 'rgb(140,245,241)';
                                    td.style.background = 'rgb(140,245,241)';
                                    if (numCell-1 == counter && parseInt(answered,10) == 1) {
                                        td.style.background = 'rgb(204,255,255)';
                                        td.style.transition = 'background 2s';
                                    }
                                }


                                tr.appendChild(td);
                                counter++;
                            }
                        }
                        rowCounter++; 
                        newTable.appendChild(tr);
                    }
                    oldTable.parentNode.replaceChild(newTable, oldTable);

                    // Update buttons
                    if (parseInt(step, 10) == maxSteps) {
                        document.getElementById("priorStepButton").style.visibility = "visible";  // visible
                        document.getElementById("priorStepText").style.visibility = "visible";
                        document.getElementById("nextStepButton").style.visibility = "hidden";   // hidden
                        document.getElementById("nextStepText").style.visibility = "hidden";
                        document.getElementById("NextProblem").style.visibility = "visible";      // visible

                    }
                    else if (parseInt(step, 10) > 1) {
                        document.getElementById("priorStepButton").style.visibility = "visible";  // visible
                        document.getElementById("priorStepText").style.visibility = "visible";
                        document.getElementById("nextStepButton").style.visibility = "visible";   // visible
                        document.getElementById("nextStepText").style.visibility = "visible";
                        document.getElementById("NextProblem").style.visibility = "hidden";      // hidden
                    }
                    else {
                        document.getElementById("priorStepButton").style.visibility = "hidden";  // hidden
                        document.getElementById("priorStepText").style.visibility = "hidden";
                        document.getElementById("nextStepButton").style.visibility = "visible";   // visible
                        document.getElementById("nextStepText").style.visibility = "visible";
                        document.getElementById("NextProblem").style.visibility = "hidden";      // hidden
                    }

                    if (parseInt(step, 10) == 0) {
                        responseCallNico("problem start");
                    }
                   
                })
                
            }            
        }

        function PriorStep_Click() {
            //clearTimeout(timer);
            __log("prior step button clicked");
            var data = new FormData();
            var clicked = "prior";
            data.append('button_info', clicked);

            $(document).ajaxStart(function () {
                $("#thinking").css("display", "block");
            });

            $(document).ajaxStop(function () {
                $("#thinking").css("display", "none");
            });

            $.ajax({
                url: "../handlers/UpdateStep.ashx",
                type: 'POST',
                data: data,
                contentType: false,
                processData: false,
                success: function (endSession) {
                    updateTable(endSession);
                    //window.clearTimeout(timer)
                    //timer = window.setTimeout(function () { responseCallNico("no response"); }, 65000);
                },
                error: function (err) {
                    alert(err.statusText)
                }
            });
            return false;
        }

        function NextStep_Click() {
            //clearTimeout(timer);
            __log("next step button clicked");
            var data = new FormData();
            var clicked = "next";
            data.append('button_info', clicked);

            $(document).ajaxStart(function () {
                $("#thinking").css("display", "block");
            });

            $(document).ajaxStop(function () {
                $("#thinking").css("display", "none");
            });

            $.ajax({
                url: "../handlers/UpdateStep.ashx",
                type: 'POST',
                data: data,
                contentType: false,
                processData: false,
                success: function (endSession) {
                    updateTable(endSession);
                   // window.clearTimeout(timer);
                   // timer = window.setTimeout(function () { responseCallNico("no response"); }, 65000);
                },
                error: function (err) {
                    alert(err.statusText)
                }
            });
            return false;
        }

        function PriorStep_Touch(evt) {
            //clearTimeout(timer);
            evt.preventDefault();
            __log("prior step button clicked");
            var data = new FormData();
            var clicked = "prior";
            data.append('button_info', clicked);

            $(document).ajaxStart(function () {
                $("#thinking").css("display", "block");
            });

            $(document).ajaxStop(function () {
                $("#thinking").css("display", "none");
            });

            $.ajax({
                url: "../handlers/UpdateStep.ashx",
                type: 'POST',
                data: data,
                contentType: false,
                processData: false,
                success: function (endSession) {
                    updateTable(endSession);
                    //window.clearTimeout(timer);
                    //timer = window.setTimeout(function () { responseCallNico("no response"); }, 65000);
                },
                error: function (err) {
                    alert(err.statusText)
                }
            });
            return false;
        }

        function NextStep_Touch(evt) {
            //clearTimeout(timer);
            evt.preventDefault();
            __log("next step button clicked");
            var data = new FormData();
            var clicked = "next";
            data.append('button_info', clicked);

            $(document).ajaxStart(function () {
                $("#thinking").css("display", "block");
            });

            $(document).ajaxStop(function () {
                $("#thinking").css("display", "none");
            });

            $.ajax({
                url: "../handlers/UpdateStep.ashx",
                type: 'POST',
                data: data,
                contentType: false,
                processData: false,
                success: function (endSession) {
                    updateTable(endSession);
                    //window.clearTimeout(timer);
                   // timer = window.setTimeout(function () { responseCallNico("no response"); }, 65000);
                },
                error: function (err) {
                    alert(err.statusText)
                }
            });
            return false;
        }

        function Next_Problem() {
            //clearTimeout(timer);
            __log("new problem button clicked");
            var data = new FormData();
            var clicked = "problem";
            data.append('button_info', clicked);

            $(document).ajaxStart(function () {
                $("#thinking").css("display", "block");
            });

            $(document).ajaxStop(function () {
                $("#thinking").css("display", "none");
            });

            $.ajax({
                url: "../handlers/UpdateStep.ashx",
                type: 'POST',
                data: data,
                contentType: false,
                processData: false,
                success: function (endSession) {
                    updateTable(endSession);
                    //window.clearTimeout(timer);
                    //timer = window.setTimeout(function () { responseCallNico("no response"); }, 65000);
                },
                error: function (err) {
                    alert(err.statusText)
                }
            });

            return false;
            
        }


        // Window loading initializations
        window.onload = function init() {
            //var touchzone = document.getElementById('touchzone');
            //touchzone.addEventListener("touchstart", touchHandlerDown, false);
            //touchzone.addEventListener("touchend", touchHandlerUp, false);
            //preventLongPressMenu(document.getElementById('NAOButton'));



            var nextsteptouch = document.getElementById('nextsteptouch');
            var priorsteptouch = document.getElementById('priorsteptouch');
            nextsteptouch.addEventListener("touchend", NextStep_Touch, false);
            priorsteptouch.addEventListener("touchend", PriorStep_Touch, false);

            updateTable();
            
            
            //timer = window.setTimeout(function () { responseCallNico("no response"); }, 65000);


        }

        // function for writing data to window
        function __log(e, data) {
            log.innerHTML += "\n" + e + " " + (data || '');
        }

        // response if need to upgrade window
        function upgrade() {
            __log('info_upgrade');
        }

        function writeLog(message) {
            var data = new FormData();
            data.append('log', message);

            $.ajax({
                url: "../handlers/ErrorLogger.ashx",
                type: 'POST',
                data: data,
                contentType: false,
                processData: false,
                success: function () {
                },
                error: function (err) {
                    alert(err.statusText)
                }
            });
        }

    </script>

</asp:Content>