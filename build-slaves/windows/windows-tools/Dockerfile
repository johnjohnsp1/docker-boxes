FROM inetsoftware/windows-java-gradle
MAINTAINER contact@inetsoftware.de

# signtool - see sdk
# RUN choco install windows-sdk-8.1

# dev package .NET 4.5.2 - includes msbuild
# RUN choco install netfx-4.5.2-devpack

# Donwload version 1.9 of mutools from their website.
RUN @powershell -NoProfile -ExecutionPolicy Bypass -Command " \
    $storageDir = \"C:\tools\" ; \
    $muVersion = \"mupdf-1.11-windows\" ; \
    $url = \"http://www.mupdf.com/downloads/archive/$muVersion.zip\" ; \
    $file = \"$storageDir\mupdf.zip\" ; \
    mkdir $storageDir; \
    Invoke-WebRequest -Uri $url -OutFile $file; \
    Expand-Archive -LiteralPath \"$file\" -DestinationPath \"$storageDir\" ; \
    rm \"$file\" ; \
    SETX Path \"$storageDir\$muVersion\;%PATH%\" \
    ; "

# Ghostscript
RUN choco install ghostscript.app -version 9.20

# Access treiber for mdb
RUN choco install msaccess2010-redist-x64

# ODBC Driver for SQL-Server
RUN choco install sqlserver-odbcdriver

# testing ... things ...
# This is THE ONLY package that allows to install parts of VS to compile our
# SDK/Unit-based samples without installing the whole VS edition.
RUN choco install visualstudio2015testagents

# Visual C++ Build Tools - takes very long!
RUN choco install visualcppbuildtools

# Set Environment
RUN @echo off \
    && call "%VS140COMNTOOLS%vsvars32.bat" \
    && set >> C:\environment.properties \ 
    && @powershell -NoProfile -ExecutionPolicy Bypass -Command " \
        Get-Content C:\environment.properties | Foreach-Object { \
            $key = $_.trim() -replace '(.*?)=(.*)','$1' ; \
            $value = $_.trim() -replace '(.*?)=(.*)','$2' ; \
            setx /m $key \"$value\" ; \
        } \
    " \
    && del C:\environment.properties

# Unit Test Framework to create unit test tools - installed by the testagents already
# RUN nuget install Microsoft.VisualStudio.QualityTools.UnitTestFramework