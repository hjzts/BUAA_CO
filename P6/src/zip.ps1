# 设置源文件夹路径、目标压缩文件路径和要排除的文件名
$sourceFolder = $pwd
$destinationZipFile = $pwd
# $excludeFileName1 = "_DASM.v"
# $excludeFileName2 = "mips_tb.v"

# 获取所有.v文件，但排除指定的文件
# 需要排除多个指定文件
$excludeFiles = @("_DASM.v", "mips_test.v", "wave","generated_mips_test.v")
$vFiles = Get-ChildItem -Path $sourceFolder -Filter *.v | Where-Object { $_.Name -notin $excludeFiles}

# 使用Compress-Archive cmdlet来创建压缩文件
Compress-Archive -Path $vFiles.FullName -DestinationPath $destinationZipFile -Force