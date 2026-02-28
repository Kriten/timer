Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- State ---
$script:tasks = @(
    @{ Name = "Task 1"; Elapsed = [TimeSpan]::Zero; Running = $false; StartTime = $null },
    @{ Name = "Task 2"; Elapsed = [TimeSpan]::Zero; Running = $false; StartTime = $null },
    @{ Name = "Task 3"; Elapsed = [TimeSpan]::Zero; Running = $false; StartTime = $null },
    @{ Name = "Task 4"; Elapsed = [TimeSpan]::Zero; Running = $false; StartTime = $null },
    @{ Name = "Task 5"; Elapsed = [TimeSpan]::Zero; Running = $false; StartTime = $null }
)

# --- Colors ---
$clrBg        = [System.Drawing.Color]::FromArgb(30, 30, 30)
$clrPanel     = [System.Drawing.Color]::FromArgb(45, 45, 48)
$clrAccent    = [System.Drawing.Color]::FromArgb(0, 122, 204)
$clrRunning   = [System.Drawing.Color]::FromArgb(20, 150, 80)
$clrStop      = [System.Drawing.Color]::FromArgb(190, 50, 50)
$clrText      = [System.Drawing.Color]::White
$clrMuted     = [System.Drawing.Color]::FromArgb(160, 160, 160)
$clrReset     = [System.Drawing.Color]::FromArgb(80, 80, 80)

# --- Form ---
$form = New-Object System.Windows.Forms.Form
$form.Text            = "Task Timer"
$form.Size            = New-Object System.Drawing.Size(520, 560)
$form.MinimumSize     = $form.Size
$form.MaximumSize     = $form.Size
$form.BackColor       = $clrBg
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox     = $false
$form.StartPosition   = "CenterScreen"
$form.Font            = New-Object System.Drawing.Font("Segoe UI", 10)

# --- Title label ---
$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text      = "TASK TIMER"
$lblTitle.ForeColor = $clrAccent
$lblTitle.Font      = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$lblTitle.AutoSize  = $true
$lblTitle.Location  = New-Object System.Drawing.Point(20, 14)
$form.Controls.Add($lblTitle)

# --- Per-task UI rows ---
$script:rows = @()   # each element: hashtable with controls + index

$rowHeight = 72
$rowStartY = 60

for ($i = 0; $i -lt 5; $i++) {
    $y = $rowStartY + $i * ($rowHeight + 8)

    # Panel background
    $panel = New-Object System.Windows.Forms.Panel
    $panel.Size      = New-Object System.Drawing.Size(476, $rowHeight)
    $panel.Location  = New-Object System.Drawing.Point(20, $y)
    $panel.BackColor = $clrPanel

    # Task name label (editable on double-click)
    $lblName = New-Object System.Windows.Forms.Label
    $lblName.Text      = $script:tasks[$i].Name
    $lblName.ForeColor = $clrText
    $lblName.Font      = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    $lblName.Location  = New-Object System.Drawing.Point(12, 8)
    $lblName.Size      = New-Object System.Drawing.Size(200, 24)
    $lblName.Tag       = $i   # task index

    # Inline edit box (hidden until double-click)
    $txtEdit = New-Object System.Windows.Forms.TextBox
    $txtEdit.Location  = New-Object System.Drawing.Point(12, 6)
    $txtEdit.Size      = New-Object System.Drawing.Size(200, 24)
    $txtEdit.Visible   = $false
    $txtEdit.Tag       = $i

    # Timer display
    $lblTime = New-Object System.Windows.Forms.Label
    $lblTime.Text      = "00:00:00"
    $lblTime.ForeColor = $clrMuted
    $lblTime.Font      = New-Object System.Drawing.Font("Consolas", 18, [System.Drawing.FontStyle]::Bold)
    $lblTime.Location  = New-Object System.Drawing.Point(12, 34)
    $lblTime.Size      = New-Object System.Drawing.Size(200, 30)

    # Start/Stop button
    $btnToggle = New-Object System.Windows.Forms.Button
    $btnToggle.Text      = "Start"
    $btnToggle.Size      = New-Object System.Drawing.Size(80, 30)
    $btnToggle.Location  = New-Object System.Drawing.Point(268, 20)
    $btnToggle.FlatStyle = "Flat"
    $btnToggle.BackColor = $clrAccent
    $btnToggle.ForeColor = $clrText
    $btnToggle.FlatAppearance.BorderSize = 0
    $btnToggle.Tag       = $i

    # Reset button
    $btnReset = New-Object System.Windows.Forms.Button
    $btnReset.Text      = "Reset"
    $btnReset.Size      = New-Object System.Drawing.Size(80, 30)
    $btnReset.Location  = New-Object System.Drawing.Point(372, 20)
    $btnReset.FlatStyle = "Flat"
    $btnReset.BackColor = $clrReset
    $btnReset.ForeColor = $clrText
    $btnReset.FlatAppearance.BorderSize = 0
    $btnReset.Tag       = $i

    $panel.Controls.AddRange(@($lblName, $txtEdit, $lblTime, $btnToggle, $btnReset))
    $form.Controls.Add($panel)

    $script:rows += @{
        Panel     = $panel
        LblName   = $lblName
        TxtEdit   = $txtEdit
        LblTime   = $lblTime
        BtnToggle = $btnToggle
        BtnReset  = $btnReset
        Index     = $i
    }
}

# --- Total label ---
$lblTotal = New-Object System.Windows.Forms.Label
$lblTotal.Text      = "Total: 00:00:00"
$lblTotal.ForeColor = $clrMuted
$lblTotal.Font      = New-Object System.Drawing.Font("Segoe UI", 10)
$lblTotal.Location  = New-Object System.Drawing.Point(20, 510)
$lblTotal.AutoSize  = $true
$form.Controls.Add($lblTotal)

# --- Stop All button ---
$btnStopAll = New-Object System.Windows.Forms.Button
$btnStopAll.Text      = "Stop All"
$btnStopAll.Size      = New-Object System.Drawing.Size(100, 30)
$btnStopAll.Location  = New-Object System.Drawing.Point(296, 505)
$btnStopAll.FlatStyle = "Flat"
$btnStopAll.BackColor = $clrStop
$btnStopAll.ForeColor = $clrText
$btnStopAll.FlatAppearance.BorderSize = 0
$form.Controls.Add($btnStopAll)

# --- Reset All button ---
$btnResetAll = New-Object System.Windows.Forms.Button
$btnResetAll.Text      = "Reset All"
$btnResetAll.Size      = New-Object System.Drawing.Size(100, 30)
$btnResetAll.Location  = New-Object System.Drawing.Point(400, 505)
$btnResetAll.FlatStyle = "Flat"
$btnResetAll.BackColor = $clrReset
$btnResetAll.ForeColor = $clrText
$btnResetAll.FlatAppearance.BorderSize = 0
$form.Controls.Add($btnResetAll)

# --- Helper: format timespan ---
function Format-Time([TimeSpan]$ts) {
    "{0:D2}:{1:D2}:{2:D2}" -f [int]$ts.TotalHours, $ts.Minutes, $ts.Seconds
}

# --- Helper: update one row's display ---
function Update-Row($row) {
    $i    = $row.Index
    $task = $script:tasks[$i]

    $current = $task.Elapsed
    if ($task.Running) {
        $current = $task.Elapsed + ([DateTime]::Now - $task.StartTime)
        $row.LblTime.ForeColor = $clrRunning
        $row.Panel.BackColor   = [System.Drawing.Color]::FromArgb(40, 60, 40)
        $row.BtnToggle.Text      = "Stop"
        $row.BtnToggle.BackColor = $clrStop
    } else {
        $row.LblTime.ForeColor   = $clrMuted
        $row.Panel.BackColor     = $clrPanel
        $row.BtnToggle.Text      = "Start"
        $row.BtnToggle.BackColor = $clrAccent
    }
    $row.LblTime.Text = Format-Time $current
}

# --- Helper: update total ---
function Update-Total {
    $total = [TimeSpan]::Zero
    foreach ($task in $script:tasks) {
        $elapsed = $task.Elapsed
        if ($task.Running) { $elapsed = $task.Elapsed + ([DateTime]::Now - $task.StartTime) }
        $total += $elapsed
    }
    $lblTotal.Text = "Total: " + (Format-Time $total)
}

# --- Toggle task ---
function Toggle-Task($idx) {
    $task = $script:tasks[$idx]
    if ($task.Running) {
        # Stop
        $task.Elapsed  = $task.Elapsed + ([DateTime]::Now - $task.StartTime)
        $task.Running  = $false
        $task.StartTime = $null
    } else {
        # Stop any other running task first (only one at a time)
        for ($j = 0; $j -lt 5; $j++) {
            if ($j -ne $idx -and $script:tasks[$j].Running) {
                $script:tasks[$j].Elapsed  = $script:tasks[$j].Elapsed + ([DateTime]::Now - $script:tasks[$j].StartTime)
                $script:tasks[$j].Running  = $false
                $script:tasks[$j].StartTime = $null
                Update-Row $script:rows[$j]
            }
        }
        $task.StartTime = [DateTime]::Now
        $task.Running   = $true
    }
    Update-Row $script:rows[$idx]
}

# --- Reset task ---
function Reset-Task($idx) {
    $task = $script:tasks[$idx]
    $task.Running   = $false
    $task.StartTime = $null
    $task.Elapsed   = [TimeSpan]::Zero
    Update-Row $script:rows[$idx]
}

# --- Wire up per-row events ---
foreach ($row in $script:rows) {
    $capturedRow = $row   # capture for closure

    # Toggle button
    $row.BtnToggle.Add_Click({
        Toggle-Task $capturedRow.Index
    }.GetNewClosure())

    # Reset button
    $row.BtnReset.Add_Click({
        Reset-Task $capturedRow.Index
    }.GetNewClosure())

    # Double-click label to rename
    $row.LblName.Add_DoubleClick({
        $capturedRow.TxtEdit.Text    = $capturedRow.LblName.Text
        $capturedRow.LblName.Visible = $false
        $capturedRow.TxtEdit.Visible = $true
        $capturedRow.TxtEdit.Focus()
    }.GetNewClosure())

    # Commit rename on Enter or focus loss
    $commitRename = {
        $newName = $capturedRow.TxtEdit.Text.Trim()
        if ($newName -ne "") {
            $script:tasks[$capturedRow.Index].Name = $newName
            $capturedRow.LblName.Text = $newName
        }
        $capturedRow.TxtEdit.Visible  = $false
        $capturedRow.LblName.Visible  = $true
    }.GetNewClosure()

    $row.TxtEdit.Add_KeyDown({
        param($s, $e)
        if ($e.KeyCode -eq [System.Windows.Forms.Keys]::Enter) { & $commitRename }
        if ($e.KeyCode -eq [System.Windows.Forms.Keys]::Escape) {
            $capturedRow.TxtEdit.Visible = $false
            $capturedRow.LblName.Visible = $true
        }
    }.GetNewClosure())

    $row.TxtEdit.Add_LostFocus($commitRename)
}

# --- Stop All ---
$btnStopAll.Add_Click({
    for ($i = 0; $i -lt 5; $i++) {
        if ($script:tasks[$i].Running) {
            $script:tasks[$i].Elapsed  = $script:tasks[$i].Elapsed + ([DateTime]::Now - $script:tasks[$i].StartTime)
            $script:tasks[$i].Running  = $false
            $script:tasks[$i].StartTime = $null
            Update-Row $script:rows[$i]
        }
    }
})

# --- Reset All ---
$btnResetAll.Add_Click({
    $result = [System.Windows.Forms.MessageBox]::Show(
        "Reset all task timers?", "Reset All",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning)
    if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
        for ($i = 0; $i -lt 5; $i++) { Reset-Task $i }
    }
})

# --- Tick timer (updates display every second) ---
$ticker = New-Object System.Windows.Forms.Timer
$ticker.Interval = 1000
$ticker.Add_Tick({
    foreach ($row in $script:rows) { Update-Row $row }
    Update-Total
})
$ticker.Start()

# --- Cleanup on close ---
$form.Add_FormClosing({ $ticker.Stop(); $ticker.Dispose() })

# --- Show ---
[System.Windows.Forms.Application]::Run($form)
