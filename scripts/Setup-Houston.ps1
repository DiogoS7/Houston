<#
.SYNOPSIS
  Builds the Houston data model in a Dataverse environment and loads the seed data.

.DESCRIPTION
  Creates (only if missing):
    - publisher "diogosantos" with prefix "hou"
    - solution "Houston"
    - 9 tables with their columns, choices, lookups and autonumbers
  Then publishes the customisations and loads the CSVs in /data.
  Safe to run again: anything that already exists is skipped.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File scripts\Setup-Houston.ps1 -OrgUrl https://orgxxxx.crm4.dynamics.com
#>
param(
  [Parameter(Mandatory = $true)][string]$OrgUrl,
  [switch]$SkipData
)

$ErrorActionPreference = 'Stop'
$OrgUrl = $OrgUrl.TrimEnd('/')
$Api = "$OrgUrl/api/data/v9.2"
$Solution = 'Houston'
$PublisherName = 'diogosantos'
$Prefix = 'hou'
$OptionPrefix = 74100            # choice values start at 741000000
$DataDir = Join-Path $PSScriptRoot '..\data'

# ---------------------------------------------------------------- sign in
function Get-Token {
  # Device-code sign-in with Microsoft's public Azure CLI client (no app registration needed).
  $clientId = '04b07795-8ddb-461a-bbee-02f9e1bf7b46'
  $scope = "$OrgUrl/.default offline_access"
  $dc = Invoke-RestMethod -Method Post -Uri 'https://login.microsoftonline.com/organizations/oauth2/v2.0/devicecode' `
    -Body @{ client_id = $clientId; scope = $scope }
  Write-Host ''
  Write-Host $dc.message -ForegroundColor Yellow
  Write-Host '(Sign in with your diogo@...onmicrosoft.com account.)' -ForegroundColor Yellow
  while ($true) {
    Start-Sleep -Seconds $dc.interval
    try {
      $t = Invoke-RestMethod -Method Post -Uri 'https://login.microsoftonline.com/organizations/oauth2/v2.0/token' -Body @{
        grant_type = 'urn:ietf:params:oauth:grant-type:device_code'; client_id = $clientId; device_code = $dc.device_code }
      return $t.access_token
    } catch {
      $err = ($_.ErrorDetails.Message | ConvertFrom-Json -ErrorAction SilentlyContinue).error
      if ($err -ne 'authorization_pending' -and $err -ne 'slow_down') { throw "Sign-in failed: $err" }
    }
  }
}

$script:Token = Get-Token
Write-Host 'Signed in.' -ForegroundColor Green

function Invoke-Dv {
  param([string]$Method, [string]$Path, $Body, [switch]$Return, [switch]$InSolution)
  $headers = @{
    Authorization      = "Bearer $script:Token"
    'OData-MaxVersion' = '4.0'
    'OData-Version'    = '4.0'
    Accept             = 'application/json'
  }
  if ($Return) { $headers['Prefer'] = 'return=representation' }
  if ($InSolution) { $headers['MSCRM.SolutionUniqueName'] = $Solution }
  $uri = if ($Path -like 'http*') { $Path } else { "$Api/$Path" }
  $params = @{ Method = $Method; Uri = $uri; Headers = $headers }
  if ($null -ne $Body) {
    $json = $Body | ConvertTo-Json -Depth 30 -Compress
    $params.Body = [Text.Encoding]::UTF8.GetBytes($json)
    $params.ContentType = 'application/json; charset=utf-8'
  }
  try { Invoke-RestMethod @params }
  catch {
    $msg = $_.ErrorDetails.Message
    throw "Dataverse $Method $Path failed: $msg"
  }
}

# ---------------------------------------------------------------- helpers
$Lang = (Invoke-Dv GET 'organizations?$select=languagecode').value[0].languagecode
function L([string]$text) { @{ LocalizedLabels = @(@{ Label = $text; LanguageCode = $Lang }) } }
$Req = @{ Value = 'None'; CanBeChanged = $true; ManagedPropertyLogicalName = 'canmodifyrequirementlevelsettings' }

function Test-Table([string]$logical) {
  $r = Invoke-Dv GET "EntityDefinitions?`$select=LogicalName&`$filter=LogicalName eq '$logical'"
  return $r.value.Count -gt 0
}
function Test-Column([string]$table, [string]$logical) {
  $r = Invoke-Dv GET "EntityDefinitions(LogicalName='$table')/Attributes?`$select=LogicalName&`$filter=LogicalName eq '$logical'"
  return $r.value.Count -gt 0
}

# ---------------------------------------------------------------- publisher + solution
$pub = (Invoke-Dv GET "publishers?`$select=publisherid,customizationprefix&`$filter=uniquename eq '$PublisherName'").value
if ($pub.Count -eq 0) {
  $pub = Invoke-Dv POST 'publishers' -Return @{
    uniquename = $PublisherName; friendlyname = 'Diogo Santos'
    customizationprefix = $Prefix; customizationoptionvalueprefix = $OptionPrefix
  }
  Write-Host "Created publisher '$PublisherName' (prefix $Prefix)" -ForegroundColor Green
} else { $pub = $pub[0]; Write-Host "Publisher '$PublisherName' already exists" }

$sol = (Invoke-Dv GET "solutions?`$select=solutionid&`$filter=uniquename eq '$Solution'").value
if ($sol.Count -eq 0) {
  Invoke-Dv POST 'solutions' @{
    uniquename = $Solution; friendlyname = 'Houston'; version = '1.0.0.0'
    description = 'Houston, we have a solution. Consulting delivery platform.'
    'publisherid@odata.bind' = "/publishers($($pub.publisherid))"
  } | Out-Null
  Write-Host "Created solution '$Solution'" -ForegroundColor Green
} else { Write-Host "Solution '$Solution' already exists" }

# ---------------------------------------------------------------- data model
# Tables: logical name, display, plural, primary column label, autonumber format (optional)
$Tables = @(
  @{ N = 'skill';           D = 'Skill';            P = 'Skills';            Pk = 'Name' }
  @{ N = 'client';          D = 'Client';           P = 'Clients';           Pk = 'Name' }
  @{ N = 'consultant';      D = 'Consultant';       P = 'Consultants';       Pk = 'Name' }
  @{ N = 'engagement';      D = 'Engagement';       P = 'Engagements';       Pk = 'Name' }
  @{ N = 'consultantskill'; D = 'Consultant Skill'; P = 'Consultant Skills'; Pk = 'Reference'; Auto = 'CS-{SEQNUM:5}' }
  @{ N = 'engagementskill'; D = 'Engagement Skill'; P = 'Engagement Skills'; Pk = 'Reference'; Auto = 'ES-{SEQNUM:5}' }
  @{ N = 'assignment';      D = 'Assignment';       P = 'Assignments';       Pk = 'Reference'; Auto = 'ASG-{SEQNUM:5}' }
  @{ N = 'timesheet';       D = 'Timesheet';        P = 'Timesheets';        Pk = 'Name' }
  @{ N = 'timeentry';       D = 'Time Entry';       P = 'Time Entries';      Pk = 'Reference'; Auto = 'TE-{SEQNUM:6}' }
)

# Columns: table, schema suffix, label, type, extra
$Choices = @{
  'skill.category'      = @('Technical', 'Functional', 'Platform')
  'client.industry'     = @('Banking', 'Insurance', 'Retail', 'Public Sector', 'Utilities')
  'consultant.grade'    = @('Analyst', 'Consultant', 'Senior Consultant', 'Manager')
  'consultant.practice' = @('Power Platform', 'Salesforce', 'Data & AI', 'Business Analysis')
  'engagement.status'   = @('Pipeline', 'Active', 'Closed')
  'timesheet.status'    = @('Draft', 'Submitted', 'Approved', 'Rejected')
}
$Columns = @(
  @{ T = 'skill';           S = 'Category';          L = 'Category';           Type = 'Choice' }
  @{ T = 'client';          S = 'Industry';          L = 'Industry';           Type = 'Choice' }
  @{ T = 'client';          S = 'Country';           L = 'Country';            Type = 'Text' }
  @{ T = 'consultant';      S = 'Email';             L = 'Email';              Type = 'Email' }
  @{ T = 'consultant';      S = 'Grade';             L = 'Grade';              Type = 'Choice' }
  @{ T = 'consultant';      S = 'Practice';          L = 'Practice';           Type = 'Choice' }
  @{ T = 'consultant';      S = 'TargetUtilisation'; L = 'Target Utilisation'; Type = 'Int'; Min = 0; Max = 100 }
  @{ T = 'engagement';      S = 'StartDate';         L = 'Start Date';         Type = 'Date' }
  @{ T = 'engagement';      S = 'EndDate';           L = 'End Date';           Type = 'Date' }
  @{ T = 'engagement';      S = 'Status';            L = 'Engagement Status';  Type = 'Choice' }
  @{ T = 'engagement';      S = 'Billable';          L = 'Billable';           Type = 'YesNo'; Default = $true }
  @{ T = 'consultantskill'; S = 'Proficiency';       L = 'Proficiency';        Type = 'Int'; Min = 1; Max = 5 }
  @{ T = 'consultantskill'; S = 'LastUsed';          L = 'Last Used';          Type = 'Date' }
  @{ T = 'engagementskill'; S = 'RequiredLevel';     L = 'Required Level';     Type = 'Int'; Min = 1; Max = 5 }
  @{ T = 'engagementskill'; S = 'Headcount';         L = 'Headcount';          Type = 'Int'; Min = 1; Max = 50 }
  @{ T = 'assignment';      S = 'Allocation';        L = 'Allocation %';       Type = 'Int'; Min = 0; Max = 100 }
  @{ T = 'assignment';      S = 'StartDate';         L = 'Start Date';         Type = 'Date' }
  @{ T = 'assignment';      S = 'EndDate';           L = 'End Date';           Type = 'Date' }
  @{ T = 'timesheet';       S = 'WeekStart';         L = 'Week Start';         Type = 'Date' }
  @{ T = 'timesheet';       S = 'Status';            L = 'Approval Status';    Type = 'Choice' }
  @{ T = 'timesheet';       S = 'DecisionDate';      L = 'Decision Date';      Type = 'DateTime' }
  @{ T = 'timesheet';       S = 'Comment';           L = 'Comment';            Type = 'Memo' }
  @{ T = 'timeentry';       S = 'Date';              L = 'Date';               Type = 'Date' }
  @{ T = 'timeentry';       S = 'Hours';             L = 'Hours';              Type = 'Decimal'; Min = 0; Max = 24 }
  @{ T = 'timeentry';       S = 'Billable';          L = 'Billable';           Type = 'YesNo'; Default = $true }
)

# Lookups: child table, lookup schema suffix, label, parent table, parental (cascade delete)
$Lookups = @(
  @{ T = 'consultant';      S = 'Manager';    L = 'Manager';    P = 'consultant' }
  @{ T = 'engagement';      S = 'Client';     L = 'Client';     P = 'client' }
  @{ T = 'consultantskill'; S = 'Consultant'; L = 'Consultant'; P = 'consultant' }
  @{ T = 'consultantskill'; S = 'Skill';      L = 'Skill';      P = 'skill' }
  @{ T = 'engagementskill'; S = 'Engagement'; L = 'Engagement'; P = 'engagement' }
  @{ T = 'engagementskill'; S = 'Skill';      L = 'Skill';      P = 'skill' }
  @{ T = 'assignment';      S = 'Consultant'; L = 'Consultant'; P = 'consultant' }
  @{ T = 'assignment';      S = 'Engagement'; L = 'Engagement'; P = 'engagement' }
  @{ T = 'timesheet';       S = 'Consultant'; L = 'Consultant'; P = 'consultant' }
  @{ T = 'timesheet';       S = 'Approver';   L = 'Approver';   P = 'consultant' }
  @{ T = 'timeentry';       S = 'Timesheet';  L = 'Timesheet';  P = 'timesheet'; Parental = $true }
  @{ T = 'timeentry';       S = 'Engagement'; L = 'Engagement'; P = 'engagement' }
)

function Get-ChoiceValues([string]$key) {
  $i = 0; $map = [ordered]@{}
  foreach ($label in $Choices[$key]) { $map[$label] = ($OptionPrefix * 10000) + $i; $i++ }
  return $map
}

Write-Host "`nTables" -ForegroundColor Cyan
foreach ($t in $Tables) {
  $logical = "${Prefix}_$($t.N)"
  if (Test-Table $logical) { Write-Host "  = $($t.D)"; continue }
  $pk = @{
    '@odata.type' = 'Microsoft.Dynamics.CRM.StringAttributeMetadata'
    AttributeType = 'String'; AttributeTypeName = @{ Value = 'StringType' }
    SchemaName = "${Prefix}_Name"; IsPrimaryName = $true; MaxLength = 200
    FormatName = @{ Value = 'Text' }; RequiredLevel = $Req; DisplayName = (L $t.Pk)
  }
  if ($t.Auto) { $pk.AutoNumberFormat = $t.Auto }
  Invoke-Dv POST 'EntityDefinitions' -InSolution @{
    '@odata.type' = 'Microsoft.Dynamics.CRM.EntityMetadata'
    SchemaName = "${Prefix}_$((Get-Culture).TextInfo.ToTitleCase($t.D) -replace ' ','')"
    DisplayName = (L $t.D); DisplayCollectionName = (L $t.P); Description = (L "Houston $($t.D)")
    OwnershipType = 'UserOwned'; HasActivities = $false; HasNotes = $true; IsActivity = $false
    Attributes = @($pk)
  } | Out-Null
  Write-Host "  + $($t.D)" -ForegroundColor Green
}

Write-Host "`nColumns" -ForegroundColor Cyan
foreach ($c in $Columns) {
  $table = "${Prefix}_$($c.T)"; $schema = "${Prefix}_$($c.S)"; $logical = $schema.ToLower()
  if (Test-Column $table $logical) { Write-Host "  = $($c.T).$($c.S)"; continue }
  $base = @{ SchemaName = $schema; DisplayName = (L $c.L); RequiredLevel = $Req }
  switch ($c.Type) {
    'Text'     { $base += @{ '@odata.type' = 'Microsoft.Dynamics.CRM.StringAttributeMetadata'; MaxLength = 100; FormatName = @{ Value = 'Text' } } }
    'Email'    { $base += @{ '@odata.type' = 'Microsoft.Dynamics.CRM.StringAttributeMetadata'; MaxLength = 200; FormatName = @{ Value = 'Email' } } }
    'Memo'     { $base += @{ '@odata.type' = 'Microsoft.Dynamics.CRM.MemoAttributeMetadata'; MaxLength = 2000; FormatName = @{ Value = 'TextArea' } } }
    'Int'      { $base += @{ '@odata.type' = 'Microsoft.Dynamics.CRM.IntegerAttributeMetadata'; MinValue = $c.Min; MaxValue = $c.Max; Format = 'None' } }
    'Decimal'  { $base += @{ '@odata.type' = 'Microsoft.Dynamics.CRM.DecimalAttributeMetadata'; MinValue = $c.Min; MaxValue = $c.Max; Precision = 2 } }
    'Date'     { $base += @{ '@odata.type' = 'Microsoft.Dynamics.CRM.DateTimeAttributeMetadata'; Format = 'DateOnly'; DateTimeBehavior = @{ Value = 'DateOnly' } } }
    'DateTime' { $base += @{ '@odata.type' = 'Microsoft.Dynamics.CRM.DateTimeAttributeMetadata'; Format = 'DateAndTime'; DateTimeBehavior = @{ Value = 'UserLocal' } } }
    'YesNo'    { $base += @{ '@odata.type' = 'Microsoft.Dynamics.CRM.BooleanAttributeMetadata'; DefaultValue = [bool]$c.Default
                   OptionSet = @{ OptionSetType = 'Boolean'; TrueOption = @{ Value = 1; Label = (L 'Yes') }; FalseOption = @{ Value = 0; Label = (L 'No') } } } }
    'Choice'   {
      $vals = Get-ChoiceValues "$($c.T).$($c.S.ToLower())"
      $opts = @(); foreach ($k in $vals.Keys) { $opts += @{ Value = $vals[$k]; Label = (L $k) } }
      $base += @{ '@odata.type' = 'Microsoft.Dynamics.CRM.PicklistAttributeMetadata'
        OptionSet = @{ '@odata.type' = 'Microsoft.Dynamics.CRM.OptionSetMetadata'; IsGlobal = $false; OptionSetType = 'Picklist'; Options = $opts } } }
  }
  Invoke-Dv POST "EntityDefinitions(LogicalName='$table')/Attributes" -InSolution $base | Out-Null
  Write-Host "  + $($c.T).$($c.S)" -ForegroundColor Green
}

Write-Host "`nLookups" -ForegroundColor Cyan
foreach ($l in $Lookups) {
  $child = "${Prefix}_$($l.T)"; $parent = "${Prefix}_$($l.P)"; $schema = "${Prefix}_$($l.S)"
  if (Test-Column $child $schema.ToLower()) { Write-Host "  = $($l.T).$($l.S)"; continue }
  $delete = if ($l.Parental) { 'Cascade' } else { 'RemoveLink' }
  $cascade = if ($l.Parental) { 'Cascade' } else { 'NoCascade' }
  Invoke-Dv POST 'RelationshipDefinitions' -InSolution @{
    '@odata.type' = 'Microsoft.Dynamics.CRM.OneToManyRelationshipMetadata'
    SchemaName = "${Prefix}_$($l.P)_$($l.T)_$($l.S.ToLower())"
    ReferencedEntity = $parent; ReferencedAttribute = "${parent}id"; ReferencingEntity = $child
    CascadeConfiguration = @{ Assign = $cascade; Delete = $delete; Merge = 'NoCascade'; Reparent = $cascade; Share = $cascade; Unshare = $cascade }
    Lookup = @{
      '@odata.type' = 'Microsoft.Dynamics.CRM.LookupAttributeMetadata'
      AttributeType = 'Lookup'; AttributeTypeName = @{ Value = 'LookupType' }
      SchemaName = $schema; DisplayName = (L $l.L); RequiredLevel = $Req
    }
  } | Out-Null
  Write-Host "  + $($l.T).$($l.S) -> $($l.P)" -ForegroundColor Green
}

Write-Host "`nPublishing customisations (can take a minute)..." -ForegroundColor Cyan
Invoke-Dv POST 'PublishAllXml' @{} | Out-Null
Write-Host 'Published.' -ForegroundColor Green

if ($SkipData) { Write-Host "`nDone (data skipped)." -ForegroundColor Green; return }

# ---------------------------------------------------------------- seed data
Write-Host "`nSeed data" -ForegroundColor Cyan
$Meta = @{}
foreach ($t in $Tables) {
  $logical = "${Prefix}_$($t.N)"
  $set = (Invoke-Dv GET "EntityDefinitions(LogicalName='$logical')?`$select=EntitySetName").EntitySetName
  $nav = @{}
  foreach ($r in (Invoke-Dv GET "EntityDefinitions(LogicalName='$logical')/ManyToOneRelationships?`$select=ReferencingAttribute,ReferencingEntityNavigationPropertyName,ReferencedEntity").value) {
    $nav[$r.ReferencingAttribute] = $r
  }
  $Meta[$t.N] = @{ Set = $set; Nav = $nav }
}

$Ids = @{}   # table -> name -> id
function Import-Table([string]$table, [string]$file, [hashtable]$lookupTargets, [string[]]$skipCols = @()) {
  $m = $Meta[$table]
  $Ids[$table] = @{}
  $existing = Invoke-Dv GET "$($m.Set)?`$select=${Prefix}_name,${Prefix}_${table}id"
  if ($existing.value.Count -gt 0) {
    foreach ($e in $existing.value) { $Ids[$table][$e."${Prefix}_name"] = $e."${Prefix}_${table}id" }
    Write-Host "  = $table ($($existing.value.Count) rows already there)"; return
  }
  $rows = Import-Csv (Join-Path $DataDir $file) -Encoding UTF8
  $n = 0
  foreach ($row in $rows) {
    $body = @{}
    foreach ($p in $row.PSObject.Properties) {
      $col = $p.Name; $val = $p.Value
      if ($skipCols -contains $col -or [string]::IsNullOrEmpty($val)) { continue }
      if ($lookupTargets.ContainsKey($col)) {
        $target = $lookupTargets[$col]; $id = $Ids[$target][$val]
        if (-not $id) { throw "$file row $($n+1): '$val' not found in $target" }
        $navName = $m.Nav[$col].ReferencingEntityNavigationPropertyName
        $body["$navName@odata.bind"] = "/$($Meta[$target].Set)($id)"
      } elseif ($Choices.ContainsKey("$table.$($col.Substring($Prefix.Length + 1))")) {
        $body[$col] = (Get-ChoiceValues "$table.$($col.Substring($Prefix.Length + 1))")[$val]
      } elseif ($val -eq 'Yes' -or $val -eq 'No') {
        $body[$col] = ($val -eq 'Yes')
      } elseif ($val -match '^\d+$' -and $col -notmatch 'name') {
        $body[$col] = [int]$val
      } elseif ($val -match '^\d+\.\d+$') {
        $body[$col] = [decimal]::Parse($val, [Globalization.CultureInfo]::InvariantCulture)
      } else { $body[$col] = $val }
    }
    $created = Invoke-Dv POST $m.Set $body -Return
    if ($row.PSObject.Properties['hou_name']) { $Ids[$table][$row.hou_name] = $created."${Prefix}_${table}id" }
    $n++
    if ($n % 50 -eq 0) { Write-Host "    $table $n/$($rows.Count)..." }
  }
  Write-Host "  + $table ($n rows)" -ForegroundColor Green
}

Import-Table 'skill'      'skills.csv'      @{}
Import-Table 'client'     'clients.csv'     @{}
Import-Table 'consultant' 'consultants.csv' @{} @('hou_manager')
# second pass: managers (self-reference)
$navMgr = $Meta['consultant'].Nav['hou_manager'].ReferencingEntityNavigationPropertyName
foreach ($row in (Import-Csv (Join-Path $DataDir 'consultants.csv') -Encoding UTF8)) {
  if ($row.hou_manager) {
    Invoke-Dv PATCH "$($Meta['consultant'].Set)($($Ids['consultant'][$row.hou_name]))" @{
      "$navMgr@odata.bind" = "/$($Meta['consultant'].Set)($($Ids['consultant'][$row.hou_manager]))" } | Out-Null
  }
}
Write-Host '  + consultant managers linked' -ForegroundColor Green
Import-Table 'engagement'      'engagements.csv'       @{ hou_client = 'client' }
Import-Table 'consultantskill' 'consultant_skills.csv' @{ hou_consultant = 'consultant'; hou_skill = 'skill' }
Import-Table 'engagementskill' 'engagement_skills.csv' @{ hou_engagement = 'engagement'; hou_skill = 'skill' }
Import-Table 'assignment'      'assignments.csv'       @{ hou_consultant = 'consultant'; hou_engagement = 'engagement' }
Import-Table 'timesheet'       'timesheets.csv'        @{ hou_consultant = 'consultant'; hou_approver = 'consultant' }
Import-Table 'timeentry'       'time_entries.csv'      @{ hou_timesheet = 'timesheet'; hou_engagement = 'engagement' }

Write-Host "`nHouston, we have a solution. All done." -ForegroundColor Green
