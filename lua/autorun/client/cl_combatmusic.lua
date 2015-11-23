
--[[
MusicPacks[1] = {}
MusicPacks[1]["combat"] = {"music/austinwintory_01/startaction_01.mp3","music/austinwintory_01/startaction_02.mp3","music/austinwintory_01/bombplanted.mp3","music/austinwintory_01/roundtenseccount.mp3"}
MusicPacks[1]["defeat"] = "music/austinwintory_01/lostround.mp3"
MusicPacks[1]["victory"] = {"music/austinwintory_01/roundmvpanthem_01.mp3","music/austinwintory_01/deathcam.mp3","music/austinwintory_01/wonround.mp3"}

MusicPacks[2] = {}
MusicPacks[2]["combat"] = {"music/awolnation_01/bombtenseccount.mp3","music/awolnation_01/startaction_01.mp3","music/awolnation_01/startaction_02.mp3","music/awolnation_01/startround_01.mp3"}
MusicPacks[2]["defeat"] = "music/awolnation_01/lostround.mp3"
MusicPacks[2]["victory"] = {"music/awolnation_01/deathcam.mp3","music/awolnation_01/roundmvpanthem_01.mp3"}

MusicPacks[3] = {}
MusicPacks[3]["combat"] = {"music/beartooth_01/bombplanted.mp3","music/beartooth_01/bombtenseccount.mp3","music/beartooth_01/roundmvpanthem_01.mp3","music/beartooth_01/roundtenseccount.mp3","music/beartooth_01/startaction_01.mp3","music/beartooth_01/startaction_02.mp3","music/beartooth_01/startround_01.mp3","music/beartooth_01/startround_02.mp3"}
MusicPacks[3]["defeat"] = "music/beartooth_01/lostround.mp3"
MusicPacks[3]["victory"] = {"music/beartooth_01/deathcam.mp3","music/beartooth_01/roundmvpanthem_01.mp3","music/beartooth_01/wonround.mp3"}
--]]


local CurrentMusicPack = 1
local CurrentMusicPackTable = {}

local CurrentSound = nil

local CurrentTarget = nil
local CombatMusicIsPlaying = false
local CombatMusicKillLatch = false
local CombatMusicDeathLatch = false

local NextThink = 0
local CombatMusicStopTime = 0
local MaxNum = 5

local MusicPacks = {}
local BaseDir = "music/"
local Extension = ".mp3"
local SubDirs = {
	"austinwintory_01/",
	"awolnation_01/",
	"beartooth_01/",
	"damjanmravunac_01/",
	"danielsadowski_01/",
	"danielsadowski_02/",
	"danielsadowski_03/",
	"darude_01/",
	"dren_01/",
	"feedme_01/",
	"hotlinemiami_01/",
	"ianhultquist_01/",
	"kellybailey_01/",
	"kitheory_01/",
	"lenniemoore_01/",
	"mateomessina_01/",
	"mattlange_01/",
	"michaelbross_01/",
	"midnightriders_01/",
	"mordfustang_01/",
	"newbeatfund_01/",
	"noisia_01/",
	"proxy_01/",
	"robertallaire_01/",
	"sasha_01/",
	"seanmurray_01/",
	"skog_01/",
	"skog_02/",
	"troelsfolmann_01/",
	}

local Translation = {}
Translation["bombplanted"] = "combat"
Translation["bombtenseccount"] = "combat"
Translation["chooseteam"] = "combat"
Translation["deathcam"] = "victory"
Translation["lostround"] = "defeat"
Translation["roundmvpanthem"] = "victory"
Translation["wonround"] = "victory"
Translation["roundtenseccount"] = "combat"
Translation["startaction"] = "combat"

function GenerateMusicPack(num)

	CurrentMusicPackTable = {}

	for TranslationFile, TranslationTo in pairs (Translation) do
		for i=0,MaxNum do
			local Addition = ""
			if i~=0 then
				Addition = "_0" .. i
			end
			
			local FileToFind = BaseDir .. SubDirs[num] .. TranslationFile..Addition..Extension
			
			if file.Exists("sound/" .. FileToFind,"GAME") then
				if not (CurrentMusicPackTable[TranslationTo]) then
					CurrentMusicPackTable[TranslationTo] = {FileToFind}
				else		
					table.Add(CurrentMusicPackTable[TranslationTo],{FileToFind})
				end
				
				util.PrecacheSound(FileToFind)
				
			end
		end
	end
end

GenerateMusicPack(1)

function CombatMusicKillHandler()
	if CurrentSound then
		if CombatMusicIsPlaying == true then
			if CurrentTarget:Alive() == false and CombatMusicKillLatch == false then
				CombatMusicStopMusic()
				CombatMusicStartMusic(CombatMusicSelectTrack("victory"))
				CombatMusicKillLatch = true
			elseif CurrentTarget:Alive() == true and CombatMusicKillLatch == true then
				CombatMusicKillLatch = false
			end
		end
	end
end

function CombatMusicTargetHandler()
	if CombatMusicIsPlaying == false then
		for k,v in pairs(player.GetAll()) do	
			if v ~= LocalPlayer() then
				if IsLookingAtEntity(LocalPlayer(),v) and IsLookingAtEntity(v,LocalPlayer()) then
					if LocalPlayer():KeyDown(IN_ATTACK) then
						CombatMusicStartMusic(CombatMusicSelectTrack("combat"))
						CurrentTarget = v
					end
				end
			end
		end
	end
end

function CombatMusicStopHandler()
	if CurrentSound then
		if CombatMusicIsPlaying == true then
			if CombatMusicStopTime <= CurTime() then
				--CurrentSound:Stop()
				CombatMusicIsPlaying = false
			end
		end
	end
end

function CombatMusicDeathHandler()
	if CurrentSound then
		if CombatMusicIsPlaying == true then
			if LocalPlayer():Alive() == false and CombatMusicDeathLatch == false then
				CombatMusicStopMusic()
				CombatMusicStartMusic(CombatMusicSelectTrack("defeat"))
				CombatMusicDeathLatch = true
			elseif LocalPlayer():Alive() == true and CombatMusicDeathLatch == true then
				CombatMusicDeathLatch = false
			end
		end
	end
end

function CombatMusicThink()
	if NextThink <= CurTime() then
	
		if CurrentMusicPack > 0 then
			CombatMusicKillHandler()
			CombatMusicDeathHandler()
			CombatMusicTargetHandler()
		end
		
		CombatMusicStopHandler()
			
		NextThink = CurTime() + 0.25
	end
end
hook.Add("Think","Combat Music: Think",CombatMusicThink)

function CombatMusicChange(ply,cmd,args)
	
	local Number = tonumber(args[1]) or 0

	if not type(Number) == "number" then
		ply:ChatPrint("That is not a number. Please enter a valid number between 1 and " .. #SubDirs)
		return 
	end
	
	if Number > #SubDirs or Number <= 0 then
		ply:ChatPrint("Please enter a valid number between 0 and " .. #SubDirs)
		return
	end
	
	if Number > 0 then
		ply:ChatPrint("Changing track to " .. Number .. " (" .. SubDirs[Number] .. ")")
	else
		ply:ChatPrint("Disabling music because you're a pussy.")
	end
	
	CurrentMusicPack = Number
	GenerateMusicPack(Number)

end

concommand.Add("changemusic",CombatMusicChange)
concommand.Add("selectmusic",CombatMusicChange)

function CombatMusicList(ply,cmd,args)

	ply:ChatPrint("Music Printed. Please check console for details.")
	
	PrintTable(SubDirs)
	print("Current Track: " .. CurrentMusicPack)

end

concommand.Add("listmusic",CombatMusicList)




function CombatMusicSelectTrack(musictype)
	if CurrentMusicPackTable then
		if CurrentMusicPackTable[musictype] then
			if type(CurrentMusicPackTable[musictype]) == "string" then
				return CurrentMusicPackTable[musictype]
			elseif type(CurrentMusicPackTable[musictype]) == "table" then
				return table.Random(CurrentMusicPackTable[musictype])
			end
		end
	end
end

function IsLookingAtEntity(ply,ent)
	local directionAngle = math.rad(ply:GetFOV()) / 2
	local aimVector = ply:GetAimVector()
	local entVector = ent:GetPos() - ply:GetShootPos()
	local dotMath = aimVector:Dot(entVector) / entVector:Length()
	if ( dotMath > directionAngle) then
		if ply:IsLineOfSightClear(ent) then
			return true
		else
			return false
		end
	else
		return false
	end
end

function CombatMusicStartMusic(path)
	CurrentSound = CreateSound(LocalPlayer(),path,LocalPlayer():EntIndex())
	CurrentSound:Play()
	CombatMusicStopTime = CurTime() + (SoundDuration(path))
	CombatMusicIsPlaying = true
end

function CombatMusicStopMusic()
	CurrentSound:Stop()
	CombatMusicIsPlaying = false
end
	


