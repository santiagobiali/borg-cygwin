$BORG_PATH="C:\Borg"
$CYGMIRROR="http://mirrors.kernel.org/sourceware/cygwin/"
$BUILDPKGS="python38,python38-devel,python38-pkgconfig,python38-setuptools,python38-pip,python38-wheel,libssl-devel,libxxhash-devel,liblz4-devel,libzstd-devel,binutils,gcc-g++,git,make,openssh,email,zlib-dev,zlib-devel"

If (-Not (Test-Path "$BORG_PATH\cygwin")){
	New-Item -Path "$BORG_PATH\cygwin" -ItemType Directory
	New-Item -Path "$BORG_PATH\logs" -ItemType Directory
}
(New-Object Net.WebClient).DownloadFile('https://cygwin.com/setup-x86_64.exe', "$BORG_PATH\cygwin\setup-x86_64.exe")

echo "Installing Cygwin..."
cd "$BORG_PATH\cygwin"
Start-Process "$BORG_PATH\cygwin\setup-x86_64.exe" -ArgumentList "-a x86_64 -q -B -o -n -R $BORG_PATH\cygwin -s $CYGMIRROR -P $BUILDPKGS" -Wait
((Get-Content -path "$BORG_PATH\cygwin\etc\fstab" -Raw) -replace 'none /cygdrive cygdrive binary,posix=0,user 0 0','none / cygdrive binary,posix=0,user 0 0') | Set-Content -Path "$BORG_PATH\cygwin\etc\fstab"
((Get-Content -path "$BORG_PATH\cygwin\etc\nsswitch.conf" -Raw) -replace '# db_enum:  cache builtin','db_enum:  cache builtin') | Set-Content -Path "$BORG_PATH\cygwin\etc\nsswitch.conf"
Start-Process "$BORG_PATH\cygwin\bin\bash" -ArgumentList "--login -c 'cygserver-config'" -Wait -NoNewWindow

echo "Installing Borg into cygwin"
Start-Process "$BORG_PATH\cygwin\bin\bash" -ArgumentList "--login -c 'pip3 install -U pip'" -Wait -NoNewWindow
Start-Process "$BORG_PATH\cygwin\bin\bash" -ArgumentList "--login -c 'pip install setuptools wheel pkgconfig'" -Wait -NoNewWindow
Start-Process "$BORG_PATH\cygwin\bin\bash" -ArgumentList "--login -c 'pip install -U setuptools wheel pkgconfig'" -Wait -NoNewWindow
Start-Process "$BORG_PATH\cygwin\bin\bash" -ArgumentList "--login -c 'pip install borgbackup'" -Wait -NoNewWindow
Start-Process "$BORG_PATH\cygwin\bin\bash" -ArgumentList "--login -c 'pip install -U borgbackup'" -Wait -NoNewWindow
Start-Process "$BORG_PATH\cygwin\bin\bash" -ArgumentList "--login -c 'borg --version'" -Wait -NoNewWindow

echo .
echo .
echo .
echo .
echo .
echo "Creating Scheaduled Task:"
echo "Action: '$BORG_PATH\cygwin\bin\mintty.exe'"
echo "Argument: '--hold never /bin/sh -l /c/Borg/script.sh'"

$Script64="IyEvYmluL3NoCgpzZXQgK2UKCmJhY2t1cCgpCnsKCVJFUE9fUEFUSD0kezF9CglBUkNISVZFPSR7Mn0KCVNPVVJDRV9QQVRIPSR7M30KCUVYVFJBX1BBUkFNRVRFUlM9JHs0fQoJREFURVRJTUU9JChkYXRlICslWSVtJWQtJUglTSVTKQoJTE9HX0ZJTEU9L2MvQm9yZy9sb2dzL2JvcmdiYWNrdXBfJChiYXNlbmFtZSAiJHtSRVBPX1BBVEh9IilfIiR7QVJDSElWRX0iXyIke0RBVEVUSU1FfSIubG9nCgkKCWV4cG9ydCBCT1JHX0ZJTEVTX0NBQ0hFX1NVRkZJWD0ke0FSQ0hJVkV9CgkKCWJvcmcgY3JlYXRlIFwKCQktLXN0YXRzIFwKCQktLWNvbXByZXNzaW9uIHpsaWIsNyBcCgkJLS1ub3hhdHRycyBcCgkJLS1ub2FjbHMgJHtFWFRSQV9QQVJBTUVURVJTfSBcCgkJIiR7UkVQT19QQVRIfTo6JHtBUkNISVZFfV8ke0RBVEVUSU1FfSIgXAoJCSR7U09VUkNFX1BBVEh9IDI+PiAiJHtMT0dfRklMRX0iCgllY2hvICJSZXN1bHRhZG86ICQ/IiA+PiAiJHtMT0dfRklMRX0iCn0KCnJlcG89c3NoOi8vYmFja3Vwc2VydmVyOjIyLy9tZWRpYS9iYWNrdXBkaXNrL0JvcmcvcmVwb0JhY2t1cAoKYmFja3VwICIke3JlcG99IiAnZm9sZGVyMScgJy9jL2ZvbGRlcjEnCmJhY2t1cCAiJHtyZXBvfSIgJ3JlbW90ZWZvbGRlcicgJy8vcmVtb3Rlc2VydmVyL3NoYXJlZGZvbGRlcicKCmV4aXQgMA=="
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Script64)) | Set-Content -Path "$BORG_PATH\script.sh"

New-Item -ItemType SymbolicLink -Path "$BORG_PATH" -Name "Borg Console" -Value "$BORG_PATH\cygwin\bin\mintty.exe" | Out-Null

pause
