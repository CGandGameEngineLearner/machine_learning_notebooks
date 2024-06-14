# ���� Python ��װ�����Python�汾��������Ϊ������ָ���汾�� Python ��װ����
$pythonVersion = "3.8.6"

# ֻ���� $pythonVersion �Ĵ����ֲ��� ���������pythonǰ׺ ��Ϊ��װ·�����ļ�����
$pythonVersionNumericString = $pythonVersion -replace '\D', ''

$installerUrl = "https://mirrors.huaweicloud.com/python/"+$pythonVersion+"/python-3.8.6-amd64.exe"
$installerFile = "python-"+$pythonVersion+"-amd64.exe"

# ����Ƿ��Ѿ���װ�˴˰汾��Pyhon
$pythonInstalled = $false


# ���尲װ·��
$userInstallPath = "$env:LOCALAPPDATA\Programs\Python\Python"+$pythonVersionNumericString

try
{
    if (Test-Path "HKCU:\SOFTWARE\Python\PythonCore")
    {

        # ��ȡ��ǰWindows�û������Ѱ�װ��Python�汾
        $pythonVersions = Get-ChildItem -Path "HKCU:\SOFTWARE\Python\PythonCore" | ForEach-Object { $_.PSChildName }


        foreach ($version in $pythonVersions)
        {
            Write-Host "��⵽�������� Python "+$version
            if ($version -eq $pythonVersion)
            {
                $pythonInstalled = $true
                break
            }
        }
    }
    else
    {
        Write-Host "δ��ע����з�����python�ļ�¼��˵������û�а�װ��python"
    }
}
catch {
    Write-Host "An error occurred: $_"
}

# ������
if ($pythonInstalled)
{
    Write-Host "Python "+$pythonVersion+" �Ѱ�װ�ڼ�����ϡ�"
}
else
{
    Write-Host "Python "+$pythonVersion+" δ�ڼ�����ϰ�װ��׼���Զ���װPython "+$pythonVersion
}

Write-Host "���ڼ����У������ĵȴ�������رմ˴��ڣ�"

try{
    # ���û��װָ���汾Python ���Զ���װ
    if ($pythonInstalled -eq $false)
    {
        # ���� Python ��װ����
        Write-Host "�������� Python ��װ����..."
        Invoke-WebRequest -Uri $installerUrl -OutFile $installerFile

        # ��װ Python
        Write-Host "���ڰ�װ Python�����Ժ�..."
        # ���� Python ��װ����
        Start-Process -FilePath $installerFile -ArgumentList "/quiet", "InstallAllUsers=0", "PrependPath=1", "DefaultJustForMeTargetDir=`"$userInstallPath`"" -Wait

        # �� Python ��ӵ�ϵͳ����������
        $env:Path += ";$userInstallPath"

        # �� Python ��ӵ�ע���
        $pythonPath = Join-Path $userInstallPath "python.exe"

        $pythonKey = "HKCU:\Software\Python\PythonCore\$pythonVersion"
        New-Item -Path $pythonKey
        New-ItemProperty -Path $pythonKey -Name "(Default)" -Value $pythonVersion
        New-ItemProperty -Path $pythonKey -Name "InstallPath" -Value $userInstallPath
        New-ItemProperty -Path $pythonKey -Name "ExecutablePath" -Value $pythonPath

        # ɾ����װ����
        Write-Host "Python ��װ��ɣ�ɾ����װ����..."
        Remove-Item $installerFile

        Write-Host "Python "+$pythonVersion+" �Ѱ�װ�ɹ�"
    }


    # �������⻷��
    python -m venv venv

    # �������⻷��
    .\venv\Scripts\Activate.ps1


    .\run.bat
}
catch {
    Write-Host "�����쳣������Ϊ: $_"
}

#���н����������˳�
Pause