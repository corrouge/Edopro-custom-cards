--Ver Coeur
--Scripted by Corrouge
local s,id=GetID()
local SET_W_Nebula=0x701
local CARD_W_NEBULA_METEORITE=90075978
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:SetSPSummonOnce(id)
	--Invocation Fusion
	Fusion.AddProcMixN(c,true,true,s.matfilter,2)
	--Invocation alternative
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.altcon)
	e1:SetTarget(s.alttg)
	e1:SetOperation(s.altop)
	c:RegisterEffect(e1)
	--Ajoutez 1 monstre Reptile "Ver" de min. Niveau 5 depuis votre deck à votre main
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--Check
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetLabel(id)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		ge1:SetOperation(aux.sumreg)
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge2:SetLabel(id)
		Duel.RegisterEffect(ge2,0)
	end)
end
s.listed_series={SET_WORM,SET_W_Nebula}
s.listed_names={id,CARD_W_NEBULA_METEORITE}

function s.matfilter(c)
	return c:IsSetCard(SET_WORM) and c:IsRace(RACE_REPTILE)
end
function s.rescon(sg,e,tp,mg)
	return Duel.GetLocationCountFromEx(tp,tp,sg,e:GetHandler())>0
		and sg:FilterCount(Card.IsLocation,nil,LOCATION_HAND)==1
end

function s.spcfilter(c)
	return c:IsCode(CARD_W_NEBULA_METEORITE) and c:IsAbleToRemove()
end
function s.altcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_HAND,0,nil)
	return #g>=1
end
function s.alttg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_HAND,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=g:Select(tp,1,1,nil)
	if #sg>0 then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else
		return false
	end
end
function s.altop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
	c:SetMaterial(sg)
	sg:DeleteGroup()
	--Aucun joueur ne peut invoquer spécialement de monstres depuis l'extra deck
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,1)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA)
end


function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0	
end
function s.thfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsSetCard(SET_WORM) and c:IsLevelAbove(5) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		--Invoquez Spécialement 1 monstre Reptile depuis votre main
		if c:IsSummonType(SUMMON_TYPE_FUSION) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then 
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
			if sc then
				Duel.BreakEffect()
				Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP_ATTACK|POS_FACEDOWN_DEFENSE)
			end
		end
	end
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_REPTILE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
