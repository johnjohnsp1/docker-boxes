FROM inetsoftware/windows-chocolatey
LABEL maintainer contact@inetsoftware.de

EXPOSE 22

#This monitor is from Microsoft 
ADD ServiceMonitor.exe /ServiceMonitor.exe

#install cygwin and cyg-get
RUN choco install cygwin cyg-get

# enable cygwin installations via cyg-get
ADD https://cygwin.com/setup-x86_64.exe cygwinsetup.exe
RUN @powershell -NoProfile -ExecutionPolicy Bypass -Command "cp /cygwinsetup.exe C:/tools/cygwin ; SETX Path \"C:\tools\cygwin\bin\;%PATH%\""

# install the ssh server package
RUN cyg-get openssh

# disable password policies
RUN @powershell -NoProfile -ExecutionPolicy Bypass -Command " \
    secedit /export /cfg c:\secpol.cfg ; \
    (gc C:\secpol.cfg).replace(\"PasswordComplexity = 1\", \"PasswordComplexity = 0\") | Out-File C:\secpol.cfg ; \
    secedit /configure /db c:\windows\security\local.sdb /cfg c:\secpol.cfg /areas SECURITYPOLICY ; \
    rm -force c:\secpol.cfg -confirm:$false \
    ; "

# set the administrator active
# create a jenkins user
# set a well know password
RUN @powershell -NoProfile -ExecutionPolicy Bypass -Command " \
    net user Administrator /active:yes ; \
    net user jenkins /add /expires:never ; \
    net localgroup Administrators /add jenkins ; \
    Get-WmiObject win32_useraccount | Foreach-Object { \
    ([adsi](\"WinNT://\"+$_.caption).replace(\"\\\",\"/\")).SetPassword(\"jenkins\") } \
    ; "

# setup the sshd service 
RUN bash -c "ssh-host-config -y -u jenkins -w jenkins"

# link the previously created user account
RUN bash -c "mkpasswd -l -u jenkins > /etc/passwd && mkgroup -l > /etc/group && mkdir -p /home/jenkins"

# add the config for sshd
ADD sshd_config C:/sshd_config
RUN cp C:/sshd_config C:/tools/cygwin/etc/

# add an environment script to make sure that all variables from the system are available
ADD env.sh /env.sh
RUN cp C:/env.sh C:/tools/cygwin/etc/profile.d/

RUN mkdir C:\jenkins

# Make the passwords of the currently existing users to never expire.
RUN WMIC USERACCOUNT SET PasswordExpires=FALSE

# Temporary Hack for the 50-char-paste-bug see: https://github.com/moby/moby/issues/29646
# TODO: Remove.
WORKDIR "Program Files"
RUN rd /S /Q WindowsPowerShell\Modules\PSReadLine
WORKDIR /

# run endlessly
CMD ["C:\\ServiceMonitor.exe", "sshd"]
