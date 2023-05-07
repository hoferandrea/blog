# edit here
$strTemplateUrl = "https://raw.githubusercontent.com/hoferandrea/Sentinel-Playground-Bicep-Edition/main/mainPlayground.json"
$strUiWizardUrl = ""

# do not edit
$strBaseUrl = "https://portal.azure.com/#create/Microsoft.Template/uri"
$strEncodedTemplateUrl = [uri]::EscapeDataString($strTemplateUrl)
$strEncodedUiWizardUrl = [uri]::EscapeDataString($strUiWizardUrl)

If($strUiWizardUrl -eq ""){
    "create deploy button without ui definition..."
    $strUrl = "$strBaseUrl/$strEncodedTemplateUrl"
} Else{
    "create deploy button with ui definition..."
    $strUrl = "$strBaseUrl/$strEncodedTemplateUrl/createUIDefinitionUri/$strEncodedUiWizardUrl" 
}
"direct link: $strUrl"
"markdown: [![Deploy to Azure](https://aka.ms/deploytoazurebutton)]($strUrl)"