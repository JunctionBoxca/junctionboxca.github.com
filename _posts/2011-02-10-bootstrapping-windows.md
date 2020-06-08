---
title:      Bootstrapping Windows
created_at: 2011-02-10 12:00:00 +00:00
layout:     default
tags:       powershell
---

Finding myself back in the Windows domain I really miss package repository tools like YUM and apt-get. In what seems eons ago I used a toolset called Unattended for windows installations. It's a little rough around the edges but it gave me some interesting ideas. I put together a quick script to download some common tools I find myself using on windows servers.

Here's the general code cobbled together;

    Const BINARY = 1
    Const SAVE_CREATE_OVERWRITE = 2
    Const SAVE_CREATE_NOT_EXIST = 1
    Const ERR_DOWNLOAD_FILE_UNAVAILABLE = -1
    Const ERR_DOWNLOAD_FILE_UNSAVABLE = -2
    temp = WScript.CreateObject("Scripting.FileSystemObject").GetSpecialFolder(2).Path & "\"

    Dim http, WshShell, file_stream

    Set WshShell = WScript.CreateObject("WScript.Shell")



    download_file "http://javadl.sun.com/webapps/download/AutoDL?BundleId=44457", "jre.exe"
    WshShell.Run temp & "jre.exe /s /v ""/qn ADDLOCAL=ALL IEXPLORER=1""", 1, TRUE
    ' JRE


    ' Download a file to the temp folder and specified filename.
    '
    '
    Function download_file(src, dest)
      ' TODO: Add better error handling for http and file handles.

      Set http = CreateObject("MSXML2.ServerXMLHTTP")

      If IsNull(http) Then
        WScript.Echo "Microsoft.XmlHttp creation failed"
      End If

      http.open "GET", src, FALSE
      http.send

      Set file_stream = CreateObject("Adodb.Stream")

      file_stream.type = BINARY
      file_stream.open
      file_stream.write http.responseBody
      file_stream.saveToFile temp & dest, SAVE_CREATE_OVERWRITE 
      file_stream.close

      Set file_stream = nothing
      Set http = nothing
    End Function
