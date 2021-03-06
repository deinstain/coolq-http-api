$out_dir = $args[0]

$dll_name = "io.github.richardchien.coolqhttpapi.dll"
$dll_path = "${out_dir}\${dll_name}"
$json_name = "io.github.richardchien.coolqhttpapi.json"
$json_path = "${out_dir}\${json_name}"

Write-Output "正在转换 JSON 描述文件编码……"

$content = Get-Content "$PSScriptRoot\..\${json_name}" -Encoding UTF8 -Raw
$gb18030 = [System.Text.Encoding]::GetEncoding("GB18030")
$gb18030.GetBytes($content) | Set-Content $json_path -Encoding Byte

Write-Output "正在拷贝插件到酷 Q 应用文件夹……"

Copy-Item -Force $dll_path "C:\Applications\CQA\app\${dll_name}"
Copy-Item -Force $json_path "C:\Applications\CQA\app\${json_name}"
Copy-Item -Force $dll_path "C:\Applications\酷Q Pro\app\${dll_name}"
Copy-Item -Force $json_path "C:\Applications\酷Q Pro\app\${json_name}"

Write-Output "拷贝完成。"
