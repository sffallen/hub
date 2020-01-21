#region Version

#
# duel.ps1
#
# First playable version enables full game for 2 players
# players autonamed P1 & P2 1 role implemented "base" 4 cards implemented
#


#
# TODO
#	- 
#	- 
#
# FEATURE REQUEST
#	- Add $card[abc].AttackChance = "50" to make card attack hit probability value driven and not hard coded
#	- 
#

#endregion version

#region controls 

#region Form

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$form = New-Object System.Windows.Forms.Form
$DrawSize = New-Object System.Drawing.Size
$DrawPoint = New-Object System.Drawing.Point	
$form.Name = "form"
$form.Text = ""
$DrawSize.Width = 1000
$DrawSize.Height = 550
$form.ClientSize = $DrawSize

#endregion Form

#region gbx

$gbxP = @{}
$gbxH = @{}
$gbxPld = @{}
$btnP = @{}
$btnP["P1"] = @{}
$btnP["P2"] = @{}
$btnH = @{}
$btnH["P1"] = @{}
$btnH["P2"] = @{}

foreach ($plyr in @("P1","P2") ) {

    $plyrNum = 1
    if ($plyr -eq "P2") { $plyrNum = 2 }

	#region gbxP

	$gbxP[$plyr] = New-Object System.Windows.Forms.Groupbox
	$gbxP[$plyr].Name = "gbx" + $plyr.ToString()
	$gbxP[$plyr].Text = $plyr
	$DrawPoint.X = 0
	$DrawPoint.Y = 140 * ($plyrNUm - 1)
	$gbxP[$plyr].Location = $DrawPoint
	$DrawSize.Width = $form.Width -300
	$DrawSize.Height = 140
	$gbxP[$plyr].Size = $DrawSize
	$form.Controls.Add($gbxP[$plyr])

	#endregion gbxP
	
	#region gbxH
	
	$gbxH[$plyr] = New-Object System.Windows.Forms.Groupbox
	$gbxH[$plyr].Name = "gbxH" + $plyr.ToString()
	$gbxH[$plyr].Text = "Hnd"
	$DrawPoint.X = 20 
	$DrawPoint.Y = ($plyrNUm * 50) - 30 
	$gbxH[$plyr].Location = $DrawPoint
	$DrawSize.Width = $form.Width - 340
	$DrawSize.Height = 50
	$gbxH[$plyr].Size = $DrawSize
	$gbxP[$plyr].Controls.Add($gbxH[$plyr])
	
	#endregion gbxH
	
	
	#region gbxPld
	
	$gbxPld[$plyr] = New-Object System.Windows.Forms.Groupbox
	$gbxPld[$plyr].Name = "gbxPld" + $plyr.ToString()
	$gbxPld[$plyr].Text = "Pld"
	$DrawPoint.X = 30 
	$DrawPoint.Y = 140 - ($plyrNum * 60)  
	$gbxPld[$plyr].Location = $DrawPoint
	$DrawSize.Width = $form.Width - 360
	$DrawSize.Height = 50
	$gbxPld[$plyr].Size = $DrawSize
	$gbxP[$plyr].Controls.Add($gbxPld[$plyr])
	
	#endregion gbxPld
	
	foreach ($slot in @(1..9)) {	
	
		#region btnH

		$btnH[$plyr][$slot] = New-Object System.Windows.Forms.Button
		$btnH[$plyr][$slot].Name = "btnH["+$plyr+"]["+$slot+"]"
		$btnH[$plyr][$slot].Text = $plyr + "H: " + $slot.ToString()
        $btnH[$plyr][$slot].Visible = $False
        $btnH[$plyr][$slot].Enabled = $False
		$DrawPoint.X = 70*$slot -20
		$DrawPoint.Y = 15
		$btnH[$plyr][$slot].Location = $DrawPoint
		$DrawSize.Width = 50
		$DrawSize.Height = 30
		$btnH[$plyr][$slot].Size = $DrawSize
		$btnH[$plyr][$slot].add_Click({param($sender,$e)
		    btnHOnClick -plyr ($sender.name.split('[')[1].split(']')[0]) -slot ($sender.name.split('[')[2].split(']')[0])
		})
        $btnH[$plyr][$slot].add_MouseHover({param($sender,$e)
            $player = $sender.name.split('[')[1].split(']')[0]
            $btnSlot = [int]($sender.name.split('[')[2].split(']')[0])
		    btnHOnMouseHover -card $btnH[$player][$btnSlot].text
		})
        $btnH[$plyr][$slot].add_MouseLeave({param($sender,$e)
            $player = $sender.name.split('[')[1].split(']')[0]
            $btnSlot = [int]($sender.name.split('[')[2].split(']')[0])
		    btnHOnMouseLeave -card $btnH[$player][$btnSlot].text
    	})
		$gbxH[$plyr].Controls.Add($btnH[$plyr][$slot])

		#endregion btnH
		
		#region btnP

		$btnP[$plyr][$slot] = New-Object System.Windows.Forms.Button
		$btnP[$plyr][$slot].Name = "btnP["+$plyr+"]["+$slot+"]"
		$btnP[$plyr][$slot].Text = $plyr + "P: " + $slot.ToString()
        $btnP[$plyr][$slot].Visible = $False
        $btnp[$plyr][$slot].Enabled = $False
		$DrawPoint.X = 70 * $slot - 30
		$DrawPoint.Y = 15
		$btnP[$plyr][$slot].Location = $DrawPoint
		$DrawSize.Width = 50
		$DrawSize.Height = 30
		$btnP[$plyr][$slot].Size = $DrawSize
		$btnP[$plyr][$slot].add_Click({param($sender,$e)
		    btnPOnClick -tbp ($sender.name.split('[')[1].split(']')[0])
		})
         $btnP[$plyr][$slot].add_MouseLeave({param($sender,$e)
            $player = $sender.name.split('[')[1].split(']')[0]
            $btnSlot = [int]($sender.name.split('[')[2].split(']')[0])
		    btnHOnMouseLeave -card $btnP[$player][$btnSlot].text
		})
         $btnP[$plyr][$slot].add_MouseHover({param($sender,$e)
            $player = $sender.name.split('[')[1].split(']')[0]
            $btnSlot = [int]($sender.name.split('[')[2].split(']')[0])
		    btnHOnMouseHover -card $btnP[$player][$btnSlot].text
		})
		$gbxPld[$plyr].Controls.Add($btnP[$plyr][$slot])

		#endregion btnH
	}
}

Function btnPOnClick($plyr,$slot) {
}

Function btnHOnClick($plyr,$slot) {
	if ($duelState.currentPhase -in @("playingAttacks","playingDefends")) {
	    $slot = [int]$slot
	    $cardType = $btnH[$plyr][$slot].text
	    $player = $duelState.players[$plyr]
	    playCard -player $player -slot $slot -card $cardType
	}
	
	if ($duelState.currentPhase -in @("attackerDiscard","defenderDiscard")) {
		$slot = [int]$slot
	    $cardType = $btnH[$plyr][$slot].text
	    $player = $duelState.players[$plyr]
		discardCard -player $player -card $cardType
		discardDraw -player $player -extra 1
		nextPhase -player $player -currentPhase $duelState.currentPhase
	}
}

Function btnHonMouseHover($card) { $lblhelp.text = $cards[$card].help }

Function btnHonMouseLeave($card) { $lblhelp.text = "" 
}

#endregion gbx

#region btnNext

$btnNext = New-Object System.Windows.Forms.Button
$btnNext.Name = "btnNext"
$btnNext.Text = "Done"
$DrawPoint.X = 30
$DrawPoint.Y = 290
$btnNext.Location = $DrawPoint
$DrawSize.Width = 50
$DrawSize.Height = 30
$btnNext.Size = $DrawSize
$btnNext.add_Click({btnNextOnClick})
$form.Controls.Add($btnNext)

Function btnNextOnClick() {
    nextPhase -currentphase $duelState.currentPhase 
}

#endregion btnNext

#region lblHelp

$lblHelp = New-Object System.Windows.Forms.Label
$lblHelp.Name = "lblHelp"
$lblHelp.Text = ""
$lblHelp.TextAlign = "TopLeft" 
$DrawPoint.X = 80
$DrawPoint.Y = 290
$lblHelp.Location = $DrawPoint
$DrawSize.Width = 550
$DrawSize.Height = 30
$lblHelp.Size = $DrawSize
$form.Controls.Add($lblHelp)

#endregion lblHelp

#region lblNext

$lblNext = New-Object System.Windows.Forms.Label
$lblNext.Name = "lblNext"
$lblNext.Text = ""
$lblNext.TextAlign = "TopLeft" 
$DrawPoint.X = 80
$DrawPoint.Y = 320
$lblNext.Location = $DrawPoint
$DrawSize.Width = 200
$DrawSize.Height = 220
$lblNext.Size = $DrawSize
$form.Controls.Add($lblNext)

#endregion lblNext

#region rtbLogs

$rtbLogs = New-Object System.Windows.Forms.RichTextBox
$rtbLogs.Name = "rtbLogs"
$rtbLogs.Text = ""
$DrawPoint.X = 750
$DrawPoint.Y = 0
$rtbLogs.Location = $DrawPoint
$DrawSize.Width = 300
$DrawSize.Height = 500
$rtbLogs.Size = $DrawSize
$Form.Controls.Add($rtbLogs)

#endregion rtbLogs

#endregion controls

#region functions

Function duel($duelState) {
    $duelState = initDuel -duelState $duelState
    $duelState = loopDuel -duelState $duelState
    return $duelState
}

#region initDuel

Function initDuel($duelState) {
    $players = @{}
    $players = getPlayer($players)
    $players = getPlayer($players) 
    $duelState["players"] = $players
    $duelState["messages"] = ""
    $duelstate["currentPhase"] = "init"
    $duelstate["firstround"] = $true
    return $duelState
}

function getPlayer($players) {
    $player = @{}
    $player["name"] = getPlayerName -players $players -player $player$duelstate.player    
    if ($players.count -eq 0) { $player["mode"] = "Attack"; $duelState["attacker"] = $player.name; $gbxP["P1"].Text = "P1 A H15 E0" }
    else { $player["mode"] = "Defend"; $duelState["defender"] = $player.name; $gbxP["P2"].Text = "P2 D H15 E0" }
    $player = getPack -player $player
    $player = getStats -player $player
    $players[$player.name] = $player
    $overdraw = drawCards -player $player -amount $player.drawAmount	# WARN - UNUSED
	updateDisplay -player $player
    return $players
}

function getPlayerName($players,$player) {
#currently just assigns "P1" or "P2"
    if ($players["P1"]) { return "P2" }
    else { return "P1" } 
}

function getPack($player) {


    $packs = @{}
    #$packs["base"] = @("Attack","Block","Attack","Block","Attack","Block","Attack","Block","Attack","Block","Attack","Block","Attack","Block","Attack","Block","Attack","Block","Attack","Block")
    $packs["base"] = @("Attack","Block","Attack","Dodge","QStrke","QStrke","Block","Block","Attack","Dodge","QStrke","Dodge") 

    $pack = $packs["base"]

    $player["pack"] = $pack
    $player["deck"] = $pack
    $player["hand"] = @()
    $player["played"] = @()
    $player["discard"] = @()
    $player["outed"] = @()   

    return $player
}

function getStats($player) {
    $stats = @{}
    $stats["base"] = @{"health"=25;"energy"=0;"accuracy"=100;"dodge"=10;"block"=0}
    $stats["base"] += @{"maxhandsize" = 9;"inithandsize" = 5;"drawAmount" = 5}
    $stats["base"] += @{"attackEnergyGain" = 6;"defendEnergyGain" = 9; "maxEnergy" = 99} 
    $statType = "base"

    $player["initStats"] = @{}
    $player["role"] = $statType
    $player["health"] = $stats[$statType].health
    $player["energy"] = $stats[$statType].energy
    $player["accuracy"] = $stats[$statType].accuracy
    $player["dodge"] = $stats[$statType].dodge
	$player["block"] = $stats[$statType].block
    $player["maxhandsize"] = $stats[$statType].maxhandsize
    $player["inithandsize"] = $stats[$statType].inithandsize
	$player["drawAmount"] = $stats[$statType].drawAmount
	$player["attackEnergyGain"] = $stats[$statType].attackEnergyGain
	$player["defendEnergyGain"] = $stats[$statType].defendEnergyGain
	$player["maxEnergy"] = $stats[$statType].maxEnergy
    $player.initStats["health"] = $stats[$statType].health
    $player.initStats["energy"] = $stats[$statType].energy
    $player.initStats["accuracy"] = $stats[$statType].accuracy
    $player.initStats["dodge"] = $stats[$statType].dodge
	$player.initStats["block"] = $stats[$statType].block
    return $player
}

#endregion initDuel

#region loopDuel

Function loopDuel($duelState) {
	$attacker = $duelState.players[$duelState.attacker]	# WARN - UNUSED
    $defender = $duelState.players[$duelState.defender] # WARN - UNUSED
    nextPhase -currentPhase $duelState.currentPhase
    return $duelState
}

Function enablePlayCards($duelState, $player, $mode) {
	$playable = getPlayable -hand $player.hand -energy $player.energy -mode $player.mode
	$lblNext.Text = $player.name + " choose what you would like to play."
    foreach ($key in $btnH[$player.name].keys) {
        $btnH[$player.name][$key].enabled = $False			 
    }
	foreach ($cardType in $playable) {
		foreach ($key in $btnH[$player.name].keys) {            
			if ($cardType -eq $btnH[$player.name][$key].text) {
				$btnH[$player.name][$key].enabled = $True
			}
		}		
	}
    return $duelState
}

Function getPlayable($hand,$energy,$mode) {
    return $hand | Get-Unique | Where-Object { $cards[$_].mode -eq $mode } | Where-Object { $cards[$_].cost -le $energy }    
}

Function playCard($player,$slot,$cardType) { 
    if ($cards[$cardType].costfn -eq "none") {   
        $duelState = changeEnergy -duelState $duelState -player $player -amount (0- $cards[$cardType].cost)
        $new = moveItem -source $player.hand -destination $player.played -item $cardType
        $player.hand = $new.source
        $player.played = $new.destination
        $duelState.players[$player.name] = $player
        displayCards -player $player		
        $duelState = enablePlayCards -duelState $duelstate -player $player -mode "attack"
           
    } else {
        write-host "toDo playCard with costfn -ne none"
    }
}


Function nextPhase($currentPhase) {
	$defender = $global:duelState.players[$duelState.defender]
	$attacker = $global:duelState.players[$duelState.attacker]
	
	if (($currentPhase -eq "cleanup") -or ($currentPhase -eq "init")) { # playing Attacks
		$duelState.currentPhase = "playingAttacks"
		$btnNext.Visible = $True	
        $lblNext.Text = ""	
		$duelState = changeEnergy -duelState $duelState -player $attacker -amount $attacker.attackEnergyGain
		$duelState = enablePlayCards -duelState $duelstate -player $attacker -mode "attack" 
		
	}
	
	if ($currentPhase -eq "playingAttacks") { # attacker discard
		$duelState.currentPhase = "attackerDiscard"
		$btnNext.Visible = $False
		if ($attacker.hand.count -eq 0) {drawCards -player $attacker -amount 2; $btnNext.Visible = $true}		
		$lblNext.Text = $attacker.name + " discard a card to draw three cards "
		enableHand -player $attacker		
	}
    
    if ($currentPhase -eq "attackerDiscard") { # playing defends
		$duelState.currentPhase = "playingDefends"
		$btnNext.Visible = $True  
        $lblNext.Text = ""     
		$duelState = changeEnergy -duelState $duelState -player $defender -amount $defender.defendEnergyGain
        $duelState = enablePlayCards -duelState $duelstate -player $defender -mode "defend" 
    }
	if ($currentPhase -eq "playingDefends") { #defender discard
        $duelState.currentPhase = "defenderDiscard"
		$btnNext.Visible = $False
		if ($attacker.hand.count -eq 0) {drawCards -player $attacker -amount 1; $btnNext.Visible = $true}		
		$lblNext.Text = $defender.name + " discard a card to draw two cards "
		enableHand -player $defender		
	}
	
	if ($currentPhase -eq "defenderDiscard") { # resolving
        $lblNext.Text = "" 
        $duelState.currentPhase = "resolving"
		$duelState = resolvePlays -duelState $duelstate	
        $btnNext.Visible = $True	
    }
    if ($currentPhase -eq "resolving") { # cleanup
        $duelState.currentPhase = "cleanup"
        $lblNext.Text = $defender.name + "'s block set to 0"
        $lblNext.Text += "`n"+$defender.name + "'s dodge set to " + $defender.initStats.dodge
        $attacker.played | ForEach-Object { 
            $new = moveItem -source $attacker.played -destination $attacker.discard -item $_
            $attacker.played = $new.source
            $attacker.discard = $new.destination
        }

        $defender.played | ForEach-Object { 
            $new = moveItem -source $defender.played -destination $defender.discard -item $_
            $defender.played = $new.source
            $defender.discard = $new.destination
        }

        $defender.block = 0
        $defender.dodge = $defender.initStats.dodge
        $duelState.players[$duelState.defender].mode = "Attack"
        $duelState.defender = $attacker.name
        $duelState.players[$duelState.attacker].mode = "Defend"
        $duelState.attacker = $defender.name 
        displayCards -player $attacker
        displayCards -player $defender               
        updateDisplay -player $defender
        updateDisplay -player $attacker    
    }
}

Function resolvePlays($duelState) {
	$defender = $duelState.players[$duelState.defender]
	$attacker = $duelState.players[$duelState.attacker]
	
	$defender.played | ForEach-Object { $duelState = resolveCard -duelState $duelState -card $_ -player $defender } 
	$attacker.played | ForEach-Object { $duelState = resolveCard -duelState $duelState -card $_ -player $attacker } 
	
	return $duelState
}

Function resolveCard($duelState, $card, $player) {
	$attacker = $duelState.players[$duelState.attacker]
	$defender = $duelState.players[$duelState.defender]
	$cardfn = $cards[$card].fn
	$amount = $cards[$card].amount
	if ($cardfn -eq "Block") {
		changeBlock -player $player -amount $amount
        $lblNext.text += "`n" + $player.name + " gains block."
		updateDisplay -player $player
	}
	if ($cardfn -eq "Dodge") {
		changeDodge -player $player -amount $amount
        $lblNext.text += "`n" + $player.name + " gains dodge"
		updateDisplay -player $player
	}
	if ($cardfn -eq "Attack") {
        $rtbLogs.text += (($cards[$card].log | ForEach-Object { $_.toString() } ) -join ""  )
		$hit = attackHits -attacker $attacker -defender $defender 
		if ($hit) { applyDamage -player $defender -amount $amount }
    else { $lblNext.text += "`n" + $attacker.name + " misses " + $defender.name }
		updateDisplay -player $player
	}
	return $duelState
}

Function enableHand($player) {
	foreach( $slot in @(1..9) ) {
		if ($btnH[$player.name][$slot].Visible) { $btnH[$player.name][$slot].Enabled = $true }
	}
}

Function discardCard($player,$cardType) {
	$new = moveItem -source $player.hand -destination $player.discard -item $cardType
    $player.hand = $new.source
    $player.discard = $new.destination
	foreach( $slot in @(1..9) ) { $btnH[$player.name][$slot].Enabled = $false }	
	displayCards -player $player
}

Function discardDraw($player,$extra) {
	$amount = 1;
	if($player.mode -eq "Attack")  { if ($duelstate.firstround -eq $false) { $amount++; $duelstate.firstround = $false }  }
	$amount += $extra
	
	drawCards -player $player -amount ($amount + $extra)
	displayCards -player $player
}

#endregion loopDuel

#region General

Function drawCards($player,$amount) {
    $handsize = $player.hand.length
    $handoverdraw = $amount + $handsize - $player.maxhandsize  
    if ($handoverdraw -gt 0) { $amount -= $overdraw }
    if ($amount -gt $player.deck.length) { recycleDiscard -player $player }

    $cards = get-random -input $player.deck -count $amount
    $cards | ForEach-Object {
        $new = moveItem -source $player.deck -destination $player.hand -item $_
        $player.deck = $new.source
        $player.hand = $new.destination
    }
    displayCards -player $player
    return $overdraw
}

Function displayCards($player) {
    $count = 1
    foreach ($card in @(1..9)) {
        $btnH[$player.name][$card].visible = $False 
        $btnP[$player.name][$card].visible = $False       
    }
    foreach ($card in $player.hand) {
        $btnH[$player.name][$count].text = $card
        $btnH[$player.name][$count].visible = $True
        $count++
    }
    $count = 1
    foreach ($card in $player.played) {
        $btnP[$player.name][$count].text = $card
        $btnP[$player.name][$count].visible = $True
        $btnP[$player.name][$count].enabled = $True
        $count++
    }

    #[void]$Form.ShowDialog()

}

Function shuffle($pile) { return get-random -input $pile -count $pile.length }

Function recycleDiscard($player) {
    $player.discard = shuffle($player.discard)
    $player.deck += $player.discard
    $player.discard = @()
}

Function moveItem ($source, $destination, $item) {

    $index = $source.indexof($item)
    $length = $source.length

    $destination += $source[$index] 
       
    if ($length -eq 1) {$source = @()}
    elseif ($index -eq 0) { $source = $source[1..($length-1)] }
    elseif ($index -eq $length-1) { $source = $source[0..($length-2)] }
    else { $source = [array]($source[0..($index-1)]) + [array]($source[($index+1)..($length-1)]) }     

    $obj = @{}
    $obj["source"] = $source
    $obj["destination"] = $destination
    return $obj
}

Function changeEnergy ($duelState,$player,$amount){
	$player.energy += $amount
	if ($player.energy -gt $player.maxEnergy) { $player.energy = $player.maxEnergy }
	updateDisplay -player $player
	return $duelState
}

Function updateDisplay($player) {
	$name = $player.name
	$mode =  $player.mode.substring(0,1)
	$hp = $player.health.toString()
	$energy = $player.energy.toString()
	$block = $player.block.toString()
	$dodge = $player.dodge.toString()
	$gbxP[$player.name].text = $name+" "+$mode+" H"+$hp+" E"+$energy+" B"+$block+" D"+ $dodge 
}

Function changeBlock($player, $amount) {
	$player.block += $amount
	if ($player.block -lt 0) { $player.block = 0 }
	if ($player.block -gt 99) { $player.block = 99 }	
}

Function changeDodge($player, $amount) {
	$player.dodge += $amount
	if ($player.dodge -lt 0) { $player.dodge = 0 }
	if ($player.dodge -gt 99) { $player.dodge = 99 }	
}

Function changeHealth($player,$amount) {
	$player.health += $amount
	if ($player.health -lt 0) { $player.health = 0; $duelState.currentPhase = "Game end reached" }
	if ($player.health -gt 99) { $player.health = 99 }
}

Function attackHits($attacker, $defender, $accmod = 0, $dodmod = 0) {
	$acc = $attacker.accuracy + $accmod
	$dod = 10*($defender.dodge+$dodmod)
	$hit = $acc + $dod 
	$chance = Get-Random -Minimum 1 -Maximum $hit
	return ($acc -ge $chance) 
}

Function applyDamage($player,$amount) {
	if ($player.block -eq 0) {
		changeHealth -player $player -amount -$amount 
        $lblNext.Text += "`n" + $player.name + " is hit for " + $amount + " damage!"
	} 
	elseif ($player.block -ge $amount) {
		$player.block -= $amount
        $lblNext.Text += "`n" + $player.name + " is hit but blocks all damage!"
	}
	else {
		$amount -= $player.block
		changeHealth -player $player -amount -$amount 
		$player.block = 0
        $lblNext.Text += "`n" + $player.name + " blocks but is still hit for " + $amount + " damage!"         
	}
    updateDisplay -player $player
}

#endregion General

#endregion functions

#region Cards

$cards = @{}

$cards["Attack"] = @{}
$cards.Attack["name"] = "Attack"
$cards.Attack["mode"] = "Attack"
$cards.Attack["fn"] = "Attack"
$cards.Attack["help"] = "Costs 3 energy. Attack does 10 damage if it hits an opponent. Base chance to hit is 50%"
$cards.Attack["amount"] = 10
$cards.Attack["cost"] = 3
$cards.Attack["costfn"] = "none"
$cards.Attack["log"] = @($duelstate.attacker, " attacks ", $duelstate.defender, " for 10 damage.")
$cards.Attack["an"] = "an"

$cards["Block"] = @{}
$cards.Block["name"] = "Block"
$cards.Block["mode"] = "Defend"
$cards.Block["fn"] = "Block"
$cards.Block["help"] = "Costs 3 energy. Block prevents 6 damage if there is an incoming attack to block. Block is removed at end of the defense round."
$cards.Block["amount"] = 6
$cards.Block["cost"] = 3
$cards.Block["costfn"] = "none"
$cards.Block["an"] = "a"

$cards["QStrke"] = @{}
$cards.QStrke["name"] =  "Quick Strike"
$cards.QStrke["mode"] = "Attack"
$cards.QStrke["fn"] = "Attack"
$cards.QStrke["amount"] = 6
$cards.QStrke["cost"] = 2
$cards.QStrke["costfn"] = "none"
$cards.QStrke["an"] = "a"
$cards.QStrke["help"] = "Costs " + $cards.QStrke["cost"] + " energy. " + $cards.QStrke["name"] + " does " + $cards.QStrke["amount"] + " damage if it hits an opponent. Base chance to hit is 50%"

$cards["Dodge"] = @{}
$cards.Dodge["name"] = "Dodge"
$cards.Dodge["mode"] = "Defend"
$cards.Dodge["fn"] = "Dodge"
$cards.Dodge["help"] = "Costs 3 energy. Increases Dodge value by 10. Additional dodge is removed at end of the defense round. Normal attacks have a (Attacker Accuracy/(Attacker Accuracy + Defender Dodge)) chance to hit."
$cards.Dodge["amount"] = 10
$cards.Dodge["cost"] = 3
$cards.Dodge["costfn"] = "none"
$cards.Dodge["an"] = "a"

#endregion Cards

$duelState = @{}
$duelState = duel -duelState $duelState

$form.ShowDialog() | Out-Null