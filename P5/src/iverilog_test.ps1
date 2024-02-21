# param(
#     [Parameter()]
#     [String]$f
# )

# Write-Output "Now is testing $f"
# iverilog -o wave -y . -I . $f
$folderPath = $pwd
$fileList = Get-ChildItem -Path $folderPath -Filter "*.v" -File

foreach ($file in $fileList) {
    Write-Host "Now is testing $file"
    iverilog -o wave -y . -I . $file
}

