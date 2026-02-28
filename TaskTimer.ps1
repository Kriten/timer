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
$clrBg      = [System.Drawing.Color]::FromArgb(30, 30, 30)
$clrPanel   = [System.Drawing.Color]::FromArgb(45, 45, 48)
$clrAccent  = [System.Drawing.Color]::FromArgb(0, 122, 204)
$clrRunning = [System.Drawing.Color]::FromArgb(20, 150, 80)
$clrRunBg   = [System.Drawing.Color]::FromArgb(40, 60, 40)
$clrStop    = [System.Drawing.Color]::FromArgb(190, 50, 50)
$clrText    = [System.Drawing.Color]::White
$clrMuted   = [System.Drawing.Color]::FromArgb(160, 160, 160)
$clrReset   = [System.Drawing.Color]::FromArgb(80, 80, 80)

# --- Form ---
$form = New-Object System.Windows.Forms.Form
$form.Text            = "Task Timer"
$form.Size            = New-Object System.Drawing.Size(540, 570)
$form.MinimumSize     = New-Object System.Drawing.Size(420, 470)
$form.BackColor       = $clrBg
$form.FormBorderStyle = "Sizable"       # resizable
$form.MaximizeBox     = $true
$form.StartPosition   = "CenterScreen"
$form.Font            = New-Object System.Drawing.Font("Segoe UI", 10)

# Compute initial layout from actual ClientSize (BorderStyle already applied above)
$margin    = 20
$rowHeight = 72
$rowGap    = 8
$rowStartY = 60
$panelW    = $form.ClientSize.Width  - 2 * $margin
$clientH   = $form.ClientSize.Height

# Anchor style shortcuts
$ancTL  = [System.Windows.Forms.AnchorStyles]::Top    -bor [System.Windows.Forms.AnchorStyles]::Left
$ancTR  = [System.Windows.Forms.AnchorStyles]::Top    -bor [System.Windows.Forms.AnchorStyles]::Right
$ancTLR = [System.Windows.Forms.AnchorStyles]::Top    -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$ancBL  = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left
$ancBR  = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right

# --- Title ---
$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text      = "TASK TIMER"
$lblTitle.ForeColor = $clrAccent
$lblTitle.Font      = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$lblTitle.AutoSize  = $true
$lblTitle.Location  = New-Object System.Drawing.Point($margin, 14)
$lblTitle.Anchor    = $ancTL
$form.Controls.Add($lblTitle)

# --- Task rows ---
$script:rows = @()

for ($i = 0; $i -lt 5; $i++) {
    $y = $rowStartY + $i * ($rowHeight + $rowGap)

    # Panel (stretches horizontally with form)
    $panel = New-Object System.Windows.Forms.Panel
    $panel.Size      = New-Object System.Drawing.Size($panelW, $rowHeight)
    $panel.Location  = New-Object System.Drawing.Point($margin, $y)
    $panel.BackColor = $clrPanel
    $panel.Anchor    = $ancTLR

    # Task name label (double-click to rename)
    $lblName = New-Object System.Windows.Forms.Label
    $lblName.Text      = $script:tasks[$i].Name
    $lblName.ForeColor = $clrText
    $lblName.Font      = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    $lblName.Location  = New-Object System.Drawing.Point(12, 8)
    $lblName.Size      = New-Object System.Drawing.Size(200, 24)
    $lblName.Anchor    = $ancTL

    # Inline edit box (shown on double-click)
    $txtEdit = New-Object System.Windows.Forms.TextBox
    $txtEdit.Location  = New-Object System.Drawing.Point(12, 6)
    $txtEdit.Size      = New-Object System.Drawing.Size(200, 24)
    $txtEdit.Visible   = $false
    $txtEdit.Anchor    = $ancTL

    # Timer display
    $lblTime = New-Object System.Windows.Forms.Label
    $lblTime.Text      = "00:00:00"
    $lblTime.ForeColor = $clrMuted
    $lblTime.Font      = New-Object System.Drawing.Font("Consolas", 18, [System.Drawing.FontStyle]::Bold)
    $lblTime.Location  = New-Object System.Drawing.Point(12, 34)
    $lblTime.Size      = New-Object System.Drawing.Size(200, 30)
    $lblTime.Anchor    = $ancTL

    # Start/Stop button — Tag holds task index; anchored to right edge of panel
    $btnToggle = New-Object System.Windows.Forms.Button
    $btnToggle.Text      = "Start"
    $btnToggle.Size      = New-Object System.Drawing.Size(80, 30)
    $btnToggle.Location  = New-Object System.Drawing.Point($panelW - 184, 20)
    $btnToggle.FlatStyle = "Flat"
    $btnToggle.BackColor = $clrAccent
    $btnToggle.ForeColor = $clrText
    $btnToggle.FlatAppearance.BorderSize = 0
    $btnToggle.Tag       = $i
    $btnToggle.Anchor    = $ancTR

    # Reset button — Tag holds task index; anchored to right edge of panel
    $btnReset = New-Object System.Windows.Forms.Button
    $btnReset.Text      = "Reset"
    $btnReset.Size      = New-Object System.Drawing.Size(80, 30)
    $btnReset.Location  = New-Object System.Drawing.Point($panelW - 96, 20)
    $btnReset.FlatStyle = "Flat"
    $btnReset.BackColor = $clrReset
    $btnReset.ForeColor = $clrText
    $btnReset.FlatAppearance.BorderSize = 0
    $btnReset.Tag       = $i
    $btnReset.Anchor    = $ancTR

    # Store control cross-references in Tag so event handlers don't need closures
    $lblName.Tag = @{ Index = $i; TxtEdit = $txtEdit }
    $txtEdit.Tag = @{ Index = $i; LblName = $lblName }

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

# --- Bottom controls (anchored to bottom of form) ---
$lblTotal = New-Object System.Windows.Forms.Label
$lblTotal.Text      = "Total: 00:00:00"
$lblTotal.ForeColor = $clrMuted
$lblTotal.Font      = New-Object System.Drawing.Font("Segoe UI", 10)
$lblTotal.AutoSize  = $true
$lblTotal.Location  = New-Object System.Drawing.Point($margin, $clientH - 38)
$lblTotal.Anchor    = $ancBL
$form.Controls.Add($lblTotal)

$btnStopAll = New-Object System.Windows.Forms.Button
$btnStopAll.Text      = "Stop All"
$btnStopAll.Size      = New-Object System.Drawing.Size(100, 30)
$btnStopAll.Location  = New-Object System.Drawing.Point($form.ClientSize.Width - 220, $clientH - 40)
$btnStopAll.FlatStyle = "Flat"
$btnStopAll.BackColor = $clrStop
$btnStopAll.ForeColor = $clrText
$btnStopAll.FlatAppearance.BorderSize = 0
$btnStopAll.Anchor    = $ancBR
$form.Controls.Add($btnStopAll)

$btnResetAll = New-Object System.Windows.Forms.Button
$btnResetAll.Text      = "Reset All"
$btnResetAll.Size      = New-Object System.Drawing.Size(100, 30)
$btnResetAll.Location  = New-Object System.Drawing.Point($form.ClientSize.Width - 110, $clientH - 40)
$btnResetAll.FlatStyle = "Flat"
$btnResetAll.BackColor = $clrReset
$btnResetAll.ForeColor = $clrText
$btnResetAll.FlatAppearance.BorderSize = 0
$btnResetAll.Anchor    = $ancBR
$form.Controls.Add($btnResetAll)

# --- Helpers ---
function Format-Time([TimeSpan]$ts) {
    "{0:D2}:{1:D2}:{2:D2}" -f [int]$ts.TotalHours, $ts.Minutes, $ts.Seconds
}

function Update-Row($row) {
    $task = $script:tasks[$row.Index]
    if ($task.Running) {
        $current = $task.Elapsed + ([DateTime]::Now - $task.StartTime)
        $row.LblTime.ForeColor   = $clrRunning
        $row.Panel.BackColor     = $clrRunBg
        $row.BtnToggle.Text      = "Stop"
        $row.BtnToggle.BackColor = $clrStop
    } else {
        $current = $task.Elapsed
        $row.LblTime.ForeColor   = $clrMuted
        $row.Panel.BackColor     = $clrPanel
        $row.BtnToggle.Text      = "Start"
        $row.BtnToggle.BackColor = $clrAccent
    }
    $row.LblTime.Text = Format-Time $current
}

function Update-Total {
    $total = [TimeSpan]::Zero
    foreach ($task in $script:tasks) {
        if ($task.Running) {
            $total += $task.Elapsed + ([DateTime]::Now - $task.StartTime)
        } else {
            $total += $task.Elapsed
        }
    }
    $lblTotal.Text = "Total: " + (Format-Time $total)
}

function Toggle-Task($idx) {
    $task = $script:tasks[$idx]
    if ($task.Running) {
        $task.Elapsed   = $task.Elapsed + ([DateTime]::Now - $task.StartTime)
        $task.Running   = $false
        $task.StartTime = $null
    } else {
        # Stop any currently running task (only one at a time)
        for ($j = 0; $j -lt 5; $j++) {
            if ($j -ne $idx -and $script:tasks[$j].Running) {
                $script:tasks[$j].Elapsed   = $script:tasks[$j].Elapsed + ([DateTime]::Now - $script:tasks[$j].StartTime)
                $script:tasks[$j].Running   = $false
                $script:tasks[$j].StartTime = $null
                Update-Row $script:rows[$j]
            }
        }
        $task.StartTime = [DateTime]::Now
        $task.Running   = $true
    }
    Update-Row $script:rows[$idx]
}

function Reset-Task($idx) {
    $task = $script:tasks[$idx]
    $task.Running   = $false
    $task.StartTime = $null
    $task.Elapsed   = [TimeSpan]::Zero
    Update-Row $script:rows[$idx]
}

# --- Wire events: use $args[0].Tag (sender) — reliable in PS7, avoids $this ambiguity ---
foreach ($row in $script:rows) {

    # Buttons read index from sender.Tag via $args[0] — reliable in PS7
    $row.BtnToggle.Add_Click({ Toggle-Task ([int]$args[0].Tag) })
    $row.BtnReset.Add_Click({  Reset-Task  ([int]$args[0].Tag) })

    # Label double-click: show edit box (cross-ref stored in Tag hashtable)
    $row.LblName.Add_DoubleClick({
        $tag = $args[0].Tag
        $tag.TxtEdit.Text    = $args[0].Text
        $args[0].Visible     = $false
        $tag.TxtEdit.Visible = $true
        $tag.TxtEdit.Focus()
    })

    # TextBox key handler: Enter = commit, Escape = cancel
    $row.TxtEdit.Add_KeyDown({
        param($s, $e)
        $tag = $s.Tag
        if ($e.KeyCode -eq [System.Windows.Forms.Keys]::Enter) {
            $n = $s.Text.Trim()
            if ($n) {
                $script:tasks[$tag.Index].Name = $n
                $tag.LblName.Text = $n
            }
            $s.Visible           = $false
            $tag.LblName.Visible = $true
        }
        if ($e.KeyCode -eq [System.Windows.Forms.Keys]::Escape) {
            $s.Visible           = $false
            $tag.LblName.Visible = $true
        }
    })

    # Commit rename when focus leaves the edit box
    $row.TxtEdit.Add_LostFocus({
        $tag = $args[0].Tag
        $n = $args[0].Text.Trim()
        if ($n) {
            $script:tasks[$tag.Index].Name = $n
            $tag.LblName.Text = $n
        }
        $args[0].Visible     = $false
        $tag.LblName.Visible = $true
    })
}

# --- Stop All ---
$btnStopAll.Add_Click({
    for ($i = 0; $i -lt 5; $i++) {
        if ($script:tasks[$i].Running) {
            $script:tasks[$i].Elapsed   = $script:tasks[$i].Elapsed + ([DateTime]::Now - $script:tasks[$i].StartTime)
            $script:tasks[$i].Running   = $false
            $script:tasks[$i].StartTime = $null
            Update-Row $script:rows[$i]
        }
    }
})

# --- Reset All ---
$btnResetAll.Add_Click({
    $r = [System.Windows.Forms.MessageBox]::Show(
        "Reset all task timers?", "Reset All",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning)
    if ($r -eq [System.Windows.Forms.DialogResult]::Yes) {
        for ($i = 0; $i -lt 5; $i++) { Reset-Task $i }
    }
})

# --- Tick timer (1 second) ---
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
