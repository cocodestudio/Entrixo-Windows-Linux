[Setup]
AppName=Entrixo Secure Terminal
AppVersion=1.0
DefaultDirName={autopf}\EntrixoTerminal
DefaultGroupName=Entrixo
UninstallDisplayIcon={app}\entrixo_desktop_linux.exe
Compression=lzma
SolidCompression=yes
OutputDir=userdocs:Inno Setup Outputs
SetupIconFile=C:\entrixo_desktop_linux\assets\app_icon.ico

[Files]
Source: "C:\entrixo_desktop_linux\final_bundle\entrixo_desktop_linux.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\entrixo_desktop_linux\final_bundle\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autodesktop}\Entrixo Terminal"; Filename: "{app}\entrixo_desktop_linux.exe"
Name: "{group}\Entrixo Terminal"; Filename: "{app}\entrixo_desktop_linux.exe"

[Run]
Filename: "{app}\entrixo_desktop_linux.exe"; Description: "Launch Entrixo Terminal"; Flags: nowait postinstall skipifsilent