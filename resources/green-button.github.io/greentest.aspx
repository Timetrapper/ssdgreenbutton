<!--#include file="greentest.inc"-->
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<title>Green Button</title>
<meta name="viewport" content="width=device-width">
<meta name="description" content="{{ site.description }}">
<link rel="canonical" href="{{ site.rooturl }}{{ page.url }}">
<link rel="shortcut icon" href="favicon.ico">

<!-- Custom CSS -->
<link rel="stylesheet" href="/static/css/style.css">
<!-- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries -->
<!--[if lt IE 9]>
<script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
  <script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
<script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
<![endif]-->

<script src="//code.jquery.com/jquery-1.11.0.min.js"></script>
<script src="//code.jquery.com/jquery-migrate-1.2.1.min.js"></script>

<script type="text/javascript">

    var dropZone;

        function LoadTempIFrame(strFileName)
        {
            if((strFileName != null) && (strFileName != ""))
            {
                var iframe = document.createElement("iframe");

                // Point the IFRAME to GenerateFile, with the
                //   desired region as a querystring argument.
                iframe.src = "greentest.aspx?filename=" + strFileName;

                // This makes the IFRAME invisible to the user.
                iframe.style.display = "none";

                // Add the IFRAME to the page.  This will trigger
                //   a request to GenerateFile now.
                document.body.appendChild(iframe);
            }
        }

        $(document).ready(function ()
        {
                InitDropZone();
                InitFBs();
        });

        $("#forDownload").ready(function ()
        {
            var strFilename = document.getElementById('forDownload').getAttribute("filename");
            LoadTempIFrame(strFilename);
        });


        // Initializes the dropZone
        function InitDropZone()
        {
                dropZone = $('#dropZone');
                dropZone.removeClass('error');

                // Check if window.FileReader exists to make
                // sure the browser supports file upload

// for now just disable the drop zone. We may reinstate the dropzone later.
//dropZone.text('Browser Not Supported!');
//dropZone.addClass('hide');
//document.getElementById('dropZoneFullArea').style.visibility = 'hidden';
//return;

                if (typeof(window.FileReader) == 'undefined')
                {
                        dropZone.text('Browser Not Supported!');
                        dropZone.addClass('hide');
                        document.getElementById('dropZoneFullArea').style.visibility = 'hidden';
                                                document.getElementById('KeepFileArea').style.visibility = 'hidden';
                                                document.getElementById('KeepFileArea').innerHTML = "";
                        return;
                }
                else
                {
                        document.getElementById('ManualUploadArea').style.visibility = 'hidden';

                                                document.getElementById('ManualUploadArea').innerHTML = "";
                }

                // Add a nice drag effect
                dropZone[0].ondragover = function ()
                {
                        dropZone.addClass('hover');
                        return false;
                };

                // Remove the drag effect when stopping our drag
                dropZone[0].ondragend = function ()
                {
                        dropZone.removeClass('hover');
                        return false;
                };

                // The drop event handles the file sending
                dropZone[0].ondrop = function(event)
                {
                        dropZone.removeClass('error');
                        document.getElementById("results").innerHTML = "";

                        // Stop the browser from opening the file in the window
                        event.preventDefault();
                        dropZone.removeClass('hover');

                        // Get the file and the file reader
                        var file = event.dataTransfer.files[0];

                        // Validate file size
                        if(file.size > <%=getMaxRequestLength()%>)
                        {
                                dropZone.text('File Too Large!');
                                dropZone.addClass('error');
                                return false;
                        }

                        // Send the file
                        var xhr = new XMLHttpRequest();
                        xhr.upload.addEventListener('progress', uploadProgress, false);
                        xhr.onreadystatechange = stateChange;
                        xhr.open('POST', '/greentest.aspx', true);
                        xhr.setRequestHeader('Content-Type', 'text/xml');
                        xhr.setRequestHeader('X-FILE-NAME', file.name);
                        xhr.setRequestHeader('Scope', GetScopeString());

                        if(document.getElementById('KeepFile').checked)
                        {
                                xhr.setRequestHeader('hKeepFile', "on");
                        }
                        else
                        {
                                xhr.setRequestHeader('hKeepFile', "off");
                        }

                        if(document.getElementById('DownloadResults').checked)
                        {
                            xhr.setRequestHeader('hDownloadResults', "on");
                        }
                        else
                        {
                            xhr.setRequestHeader('hDownloadResults', "off");
                        }

                        xhr.send(file);
                };
        }


        // Show the upload progress
        function uploadProgress(event)
        {
                var percent = parseInt(event.loaded / event.total * 100);
                $('#dropZone').text('Uploading: ' + percent + '%');
        }

        function loadXMLDoc(strFile)
        {
                var strResult;

                if (window.XMLHttpRequest)
                {// code for IE7+, Firefox, Chrome, Opera, Safari
                        xmlhttp=new XMLHttpRequest();
                }
                else
                {// code for IE6, IE5
                        xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
                }
                xmlhttp.onreadystatechange=function()
                {
                        if (xmlhttp.readyState==4 && xmlhttp.status==200)
                        {
                                strResult = xmlhttp.responseText;
                        }
                }
                xmlhttp.open("GET",strFile,false);
                xmlhttp.send();

                return strResult;
        }
        /*
        function PresentResults(strScope,strFileName,strRunTime)
        {
                var strScopeList = strScope.replace("FB=","");
                var strFBs = strScopeList.split(',');

                document.getElementById("results").innerHTML = "<table class=\"GBDataTable\" width=\"100%\">";

                document.getElementById("results").innerHTML = document.getElementById("results").innerHTML + "<thead><tr><th colspan=\"4\"><h3>File: " + strFileName + " evaluated at: " + strRunTime + "<\/h3><\/th><\/tr><\/thead>";

                for (var i = 0; i < strFBs.length; i++)
                {
                        var strFile = "/Uploads/FB_" + strFBs[i] + ".html";
                        var strRes = loadXMLDoc(strFile);

                        document.getElementById("results").innerHTML = document.getElementById("results").innerHTML + "<tr><td><p> <\/p><\/td><\/tr>";
                        document.getElementById("results").innerHTML = document.getElementById("results").innerHTML + "<table class=\"GBInnerDataTable\" width=\"100%\"><thead><tr><th colspan=\"4\">Function Block [FB_" + strFBs[i] + "] results: <\/th><\/tr><\/thead><\/table>";
                        document.getElementById("results").innerHTML = document.getElementById("results").innerHTML + "<tr><td>";
                        document.getElementById("results").innerHTML = document.getElementById("results").innerHTML + strRes;
                        document.getElementById("results").innerHTML = document.getElementById("results").innerHTML + "<\/td><\/tr>";
                }

                document.getElementById("results").innerHTML = document.getElementById("results").innerHTML + "<\/table>";
        }
        */
        // Show upload complete or upload failed depending on result
        function stateChange(event)
        {
                if (event.target.readyState == 4)
                {
                        if (event.target.status == 200 || event.target.status == 304)
                        {
                                $('#dropZone').text('5) Upload Complete. Drop Another File Here to Upload.');
                                // the following code is for reference putposes in the case we revert back to AJAX rendering of results
                                //$('#results').load(event.target.getResponseHeader("FileLocation"));
                                //document.getElementById("info").innerHTML = event.target.getResponseHeader("FileLocation") + " " + event.target.getResponseHeader("Scope");
                                //PresentResults(event.target.getResponseHeader("Scope"),event.target.getResponseHeader("FileName"),event.target.getResponseHeader("RunTime"));

                                document.getElementById("results").innerHTML = event.target.responseText;
                                location.hash = "#testresults";

                                LoadTempIFrame(event.target.getResponseHeader("filename"));
                        }
                        else
                        {
                                dropZone.text('Upload Failed!');
                                dropZone.addClass('error');
                        }
                }
        }

        function GetScopeString()
        {
                var strScope = "FB=";

                var formels = document.forms['selections'].elements
                var elnum = formels.length;
                var bAddComma = false;

                for(i=0;i<elnum;i++)
                {
                                        if(formels[i].type=='checkbox')
                                        {
                                                if(formels[i].id != "KeepFile")
                                                {
                                                        if(formels[i].checked)
                                                        {
                                                                if(bAddComma)
                                                                {
                                                                        strScope = strScope + ",";
                                                                }

                                                                strScope = strScope + formels[i].name.replace("FB_","");

                                                                bAddComma = true;
                                                        }
                                                }
                                        }
                }

                return strScope;
        }

        function ClearAllChecks()
        {
                var formels = document.forms['selections'].elements;
                var elnum = formels.length;

                for(i=0;i<elnum;i++)
                {
                        if(formels[i].type=='checkbox')
                        {
                                formels[i].checked=false;
                        }
                }
        }

        function UpdateScopeInfo()
        {
            try{
                document.getElementById('Scope').value = GetScopeString();
            }
            catch(e)
            {
            }
        }

        function InitFBs()
        {
                ClearAllChecks();
                //Electricity Metering
                document.getElementById('FB_1').checked = true;
                //document.getElementById('FB_2').checked = true;
                document.getElementById('FB_4').checked = true;
                document.getElementById('FB_5').checked = true;
                document.getElementById('FB_15').checked = true;

                UpdateScopeInfo();
        }

        function KeepFileChanged()
        {

                if(document.getElementById('KeepFile').checked)
                {
                    try{
                        document.getElementById('hKeepFile').value = "on";
                    }
                    catch(e)
                    {
                    }
                }
                else
                {
                    try{
                        document.getElementById('hKeepFile').value = "off";
                    }
                    catch(e)
                    {
                    }
                }

        }

        function DownloadResultsChanged()
        {

            if(document.getElementById('DownloadResults').checked)
            {
                try{
                    document.getElementById('hDownloadResults').value = "on";
                }
                catch(e)
                {
                }
            }
            else
            {
               try{
                    document.getElementById('hDownloadResults').value = "off";
               }
               catch(e)
               {
               }
            }

        }

        function NewFile()
        {
                document.getElementById("results").innerHTML = "";
        }

        function changeFBs()
        {
                var selectBox = document.getElementById("FBSelection");
                var selectedValue = selectBox.options[selectBox.selectedIndex].value;

                ClearAllChecks();

                switch(selectedValue)
                {
                case '1':
                        //Electricity Metering
                        document.getElementById('FB_1').checked = true;
                        //document.getElementById('FB_2').checked = true;
                        document.getElementById('FB_4').checked = true;
                        document.getElementById('FB_5').checked = true;
                        document.getElementById('FB_15').checked = true;
                        break;
                case '2':
                        //Electricity Metering With Cost
                        document.getElementById('FB_1').checked = true;
                        //document.getElementById('FB_2').checked = true;
                        document.getElementById('FB_4').checked = true;
                        document.getElementById('FB_5').checked = true;
                        document.getElementById('FB_12').checked = true;
                        document.getElementById('FB_15').checked = true;
                        document.getElementById('FB_16').checked = true;
                        document.getElementById('FB_28').checked = true;
                        break;
                case '3':
                        //Gas Metering
                        document.getElementById('FB_1').checked = true;
                        //document.getElementById('FB_2').checked = true;
                        document.getElementById('FB_4').checked = true;
                        document.getElementById('FB_10').checked = true;
                        document.getElementById('FB_15').checked = true;
                        break;
                case '4':
                        //Gas Metering With Cost
                        document.getElementById('FB_1').checked = true;
                        //document.getElementById('FB_2').checked = true;
                        document.getElementById('FB_4').checked = true;
                        document.getElementById('FB_10').checked = true;
                        document.getElementById('FB_12').checked = true;
                        document.getElementById('FB_15').checked = true;
                        document.getElementById('FB_16').checked = true;
                        document.getElementById('FB_28').checked = true;
                        break;
                case '5':
                    //Temperature Metering
                    document.getElementById('FB_1').checked = true;
                    document.getElementById('FB_4').checked = true;
                    document.getElementById('FB_29').checked = true;
                    break;
                default:
                        break;
                }

                UpdateScopeInfo();
        }


//<![CDATA[

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-30243410-1']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

//]]>
</script>
<title>Green Button &mdash; Conformance Testing</title>
</head>
<body>
  <a href="https://github.com/green-button/green-button.github.io" class="fork-me"><img style="position: absolute; top: 0; right: 0; border: 0;z-index:9999;" src="https://camo.githubusercontent.com/e7bbb0521b397edbd5fe43e7f760759336b5e05f/68747470733a2f2f73332e616d617a6f6e6177732e636f6d2f6769746875622f726962626f6e732f666f726b6d655f72696768745f677265656e5f3030373230302e706e67" alt="Fork me on GitHub" data-canonical-src="https://s3.amazonaws.com/github/ribbons/forkme_right_green_007200.png"></a>
  <header class="banner" role="banner">
  <div class="section-container">
    <div class="section-content">
      <div class="banner-title">
        <a href="http://greenbuttondata.org/">
          <img class="logo" src="assets/logo.png" alt="Green Button">
          <h1>
		  Green Button
		  </h1>
        </a>
      </div>
      <div class="banner-nav">
        <nav role="navigation" class="main-nav">
          <ul>
            <li><a href="/developers">Developers</a></li>
            <li><a href="/greentest.aspx">Testing</a></li>
            <li><a href="mailto:info@greenbuttondata.org?subject=Getting%20started%20href="http://greenbuttondata.org/"reen%20Button&#038;body=Hi!%0A%0AI�d%20like%20to%20get%20started%20with%20Green%20Button.%20Could%20you%20send%20me%20more%20information?%0A%0AThanks,%0A%0A[Your%20name]%0A[Your%20organization]%0A[Your%20contact%20information]" class="btn btn-primary">Get Started</a></li>
          </ul>
        </nav>
      </div>
    </div>
  </div>
</header>

<div class="section-container content-page">
  <div class="section-content">
    <div class="main-content">

<h2>Green Button Download My Data self-test analysis:</h2>
<p>Welcome to the Green Button Download My Data file test facility. This page is designed to support self-test of Green Button Data based on the testing and certification plan being developed at UCAIug. The OpenADE task force, which was responsible for the requirements that drove the standards underlying the Green Button, is developing a conformance and certification test for Green Button. NIST is supporting the development of Green Button test tools, such as provided below, through a contract with Hypertek Inc. as part of its support for the Green Button Initiative.</p>
<p>This web page is designed to:</p>
<ul>
<li>Allow you to evaluate the inner structure of a Green Button data file based on the test plan specification.</li>
<li>Support your reporting of issues and concerns about this test plan in advance of its finalization.</li>
</ul>

<h2>TEST your Green Button Data File</h2>
<table class="GBDataTable" style="border-color:#ffffff;">
<tr>
<td>
<form id="selections" name="selections">
<table class="GBDataTable" style="border-color:#ffffff;">
<tr>
<td>You can analyze a Green Button data file following the steps below. Follow them in order.<br />
<br /></td>
</tr>
<tr>
<td>1) First select the scope of your Green Button data file from the drop down list:<br />
<br /></td>
</tr>
<tr>
<td><select id="FBSelection" onchange="changeFBs();" style="border:solid 1px #060">
<option value="1">Electricity Metering</option>
<option value="2">Electricity Metering With Cost</option>
<option value="3">Gas Metering</option>
<option value="4">Gas Metering With Cost</option>
<option value="5">Temperature Metering</option>
</select><br />
<br /></td>
</tr>
<tr>
<td>2) You can override and make additional selections of Function Blocks to test:<br />
<br /></td>
</tr>
<%EmitFBRow("FB_1","Common",false);%><%EmitFBRow("FB_2","Green Button Download My Data",true);%><%EmitFBRow("FB_3","Green Button Connect My Data",true);%><%EmitFBRow("FB_4","Interval Metering",false);%><%EmitFBRow("FB_5","Interval Electricity Metering",false);%><%EmitFBRow("FB_6","Demand Electricity Metering",false);%><%EmitFBRow("FB_7","Net Metering",false);%><%EmitFBRow("FB_8","Forward and Reverse Metering",false);%><%EmitFBRow("FB_9","Register Values",false);%><%EmitFBRow("FB_10","Gas",false);%><%EmitFBRow("FB_11","Water",false);%><%EmitFBRow("FB_12","Cost of Interval Data",false);%><%EmitFBRow("FB_13","Security and Privacy classes",true);%><%EmitFBRow("FB_14","Authorization and Authentication",true);%><%EmitFBRow("FB_15","Usage Summary",false);%><%EmitFBRow("FB_16","Usage Summary with Cost",false);%><%EmitFBRow("FB_17","Power Quality Summary",false);%><%EmitFBRow("FB_18","Multiple UsagePoints",true);%><%EmitFBRow("FB_19","Partial update data",true);%><%EmitFBRow("FB_20","Common",true);%><%EmitFBRow("FB_21","Green Button Connect My Data",true);%><%EmitFBRow("FB_22","Security and Privacy classes",true);%><%EmitFBRow("FB_23","Authorization and Authentication Third Party Role",true);%><%EmitFBRow("FB_24","Request bulk of UsagePoints from DataCustodian",true);%><%EmitFBRow("FB_25","Request of Partial Update Data",true);%><%EmitFBRow("FB_26","Respond properly to various bad or missing data",true);%><%EmitFBRow("FB_27","Usage Summary with Demands and Previous Day Attributes",false);%><%EmitFBRow("FB_28","Usage Summary Costs for Current Billing Period",false);%><%EmitFBRow("FB_29","Temperature Metering",false); %>
<tr>
<td></td>
</tr>
</table>
</form>
</td>
</tr>
</table>
<table class="GBDataTable" style="border-color:#ffffff;">
<tr>
<td>
<div id="ManualUploadArea">
<form method='post' enctype='multipart/form-data' action='greentest.aspx#testresults'><input type="hidden" name="Scope" id="Scope" /> <input type="hidden" name="hKeepFile" id="hKeepFile" value="off" /> <input type="hidden" name="hDownloadResults" id="hDownloadResults" value="off" />
3) Select a file to upload from your computer: <input type="file" name="upfile" onclick="NewFile();" /><br />
<br />
4) Please consider checking this box to allow us to keep your file on our server for further tests. Otherwise the file will be deleted after analysis:<br />
<br />
<input type="checkbox" id="KeepFile" name="KeepFile" onclick="KeepFileChanged();" /> Allow file to be saved on website<br />
<br />
5) Enable download of test results after test execution:<br />
<br />
<input type="checkbox" id="DownloadResults" name="DownloadResults" onclick="DownloadResultsChanged();" /> Download test results<br />
<br />
6) Then <input class="button" type="submit" value="Press Here" /> to upload the file and have it analyzed!</form>
<br /></div>
</td>
</tr>
<tr>
<td>
<div id="KeepFileArea">3) Please consider checking this box to allow us to keep your file on our server for further tests. Otherwise the file will be deleted after analysis:<br />
<br />
<form id="KeepFile2" name="KeepFile2"><input type="checkbox" id="KeepFile" name="KeepFile" onclick="KeepFileChanged();" /> Allow file to be saved on website</form>
<br />
4) Enable download of test results after test execustion:<br />
<br />
<form id="DownloadResults2" name="DownloadResults2"><input type="checkbox" id="DownloadResults" name="DownloadResults" onclick="DownloadResultsChanged();" /> Download test results</form>
<br />
<br />
<div id="dropZoneFullArea">
<form id="formA" runat="server" name="formA">
<div id="dropZone">5) Drop File Here to Upload.</div>
</form>
</div>
<table>
<tr>
<td></td>
</tr>
</table>
<p style="line-height:1;font-size:100%">Note: This web page was tested with the following browsers:<br />
PC: Internet Explorer V9.0.8112.16421, Fire Fox V19.0.2, Safari V5.1.7, Chrome V25.0.1364.152<br />
Mac: Fire Fox V19.0.2, Safari V6.0.2, Chrome V25.0.1364.160</p>
</div>
<div id="right"><!--<div class="badge">
<p class="last">Green Button data, based on XML and XMLSchema, is as-simple-as-it-gets and is compatible with any OS or browser.</p>
</div>-->
<div id="GreenButtonDemo" class="text_"></div>
<!--/GreenButtonDemo--></div>
<!--/right-->
<div id="footer">
<h3><a name="testresults" id="testresults">Test Results</a></h3>
<!-- <div id="info"></div> -->
<div id="results"><%GetResults();%></div>

<div id="forDownload" filename="<%GetFilename();%>"/>

<!--<div id="container" style="width: 1000px; height: 400px; margin: 0 auto"></div> -->
<div class="clear"></div>
</div>
</td>
</tr>
</table>
    </div>
  </div>
</div>
  <footer role="contentInfo" class="site-footer">
    <div class="section-container">
      <div class="section-content">
        <div class="row">
          <nav class="footer-nav">
            <ul>
              <li><a href="http://greenbuttondata.org/"><img class="logo" src="/assets/logo.png" alt="Green Button Home"></a></li>
              <li><a href="/developers">Developers</a></li>
              <li><a href="/community">Community</a></li>
              <li><a href="/greentest.aspx">Testing</a></li>
              <li><a href="mailto:info@greenbuttondata.org">Feedback</a></li>
              <li><a href="https://github.com/green-button" target="_blank"><i class="fa fa-github"></i> Github</a></li>
            </ul>
          </nav>
        </div>
        <div class="row credits">
          Green Button is an industry-lehref="http://greenbuttondata.org/" that responds to a White House call-to-action: provide electricity customers with easy access to their energy usage data in a consumer-friendly and computer-friendly format.

        </div>
      </div>
    </div>
  </footer>
  <script src="/static/js/init.js"></script>
  <script>
    (function(b,o,i,l,e,r){b.GoogleAnalyticsObject=l;b[l]||(b[l]=
    function(){(b[l].q=b[l].q||[]).push(arguments)});b[l].l=+new Date;
    e=o.createElement(i);r=o.getElementsByTagName(i)[0];
    e.src='//www.google-analytics.com/analytics.js';
    r.parentNode.insertBefore(e,r)}(window,document,'script','ga'));
    ga('create','UA-30243410-1');ga('send','pageview');
  </script>
</body>
</html>
