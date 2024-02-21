# 设置源文件夹路径、目标压缩文件路径和要排除的文件名
$sourceFolder = $pwd
$destinationZipFile = $pwd
$excludeFiles = @("_DASM.v", "F_IM.v")

# 获取所有.v文件，但排除指定的文件
$vFiles = Get-ChildItem -Path $sourceFolder -Filter *.v | Where-Object { $_.Name -notin $excludeFiles }

# 使用Compress-Archive cmdlet来创建压缩文件
Compress-Archive -Path $vFiles.FullName -DestinationPath $destinationZipFile -Update