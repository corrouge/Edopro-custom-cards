--Nécropole du Pharaon
--Scripted by Corrouge
local s,id=GetID()
function s.initial_effect(c)
	--Activation
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Gain d'ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsCode,25343280))
	e1:SetValue(s.value)
	c:RegisterEffect(e1)
	--Cherche 1 monstre Zombie avec 0 ATK ou DEF
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--Protection vos cartes dans vos M/P zones
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_SZONE,0)
	e3:SetTarget(function(e,c) return c:IsFaceup() and c:IsSpellTrap() and c~=e:GetHandler() end)
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_SZONE,0)
	e4:SetTarget(function(e,c) return c:IsFaceup() and c:IsSpellTrap() and c~=e:GetHandler() end)
	e4:SetValue(s.etg)
	c:RegisterEffect(e4)

end
s.listed_names={id,31076103,25343280}

function s.vfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsLevelBelow(2)
end
function s.value(e,c)
	local atk=0
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroup(s.vfilter,tp,LOCATION_MZONE,0,nil) 
	for tc in aux.Next(g) do
		atk=atk+tc:GetAttack()
	end
	return atk
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local code1,code2=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CODE,CHAININFO_TRIGGERING_CODE2)
	return (code1==31076103 or code2==31076103)
end
function s.thfilter(c)
	return c:IsRace(RACE_ZOMBIE) and (c:IsAttack(0) or c:IsDefense(0)) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if sc and Duel.SendtoHand(sc,nil,REASON_EFFECT) then
		Duel.ConfirmCards(1-tp,sc)
		--Ne peut ni invoquer normalement ni spécialement de monstre du même nom
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.sumlimit)
		e1:SetLabel(sc:GetCode())
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.sumlimit(e,c)
	return c:IsCode(e:GetLabel())
end

--Protection
function s.etg(e,re,rp)
	return re:IsActiveType(TYPE_MONSTER)
end
