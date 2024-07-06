--Tragédie de la Demoiselle de fortune
--Scripted by Corrouge
local s,id=GetID()
function s.initial_effect(c)
	--Banish
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.rmcon)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	--Attaque en chaine
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,4))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.cacon)
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(s.caop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={SET_FORTUNE_LADY,SET_EARTHBOUND_IMMORTAL}

function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) or c:IsSetCard(SET_EARTHBOUND_IMMORTAL)
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return #g>0 and g:FilterCount(s.cfilter,nil)==#g
end
function s.rmfilter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.levelupfilter(c)
	return c:IsSetCard(SET_FORTUNE_LADY)
end
function s.lvfilter(c)
	return c:IsSetCard(SET_FORTUNE_LADY) and c:IsLevelAbove(6)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)<1 then return end
	--Reviens sur le terrain durant la end phase
	local te1=Effect.CreateEffect(e:GetHandler())
	te1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	te1:SetCode(EVENT_PHASE+PHASE_END)
	te1:SetReset(RESET_PHASE+PHASE_END)
	te1:SetLabelObject(tc)
	te1:SetCountLimit(1)
	te1:SetOperation(s.retop)
	Duel.RegisterEffect(te1,tp)
	--Choix de l'effet
	local xg=Duel.GetMatchingGroup(s.levelupfilter,tp,LOCATION_MZONE,0,nil)
	local rg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
	local b0=0
	local b1=#xg>0
	local b2=#rg>0 and Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_MZONE,0,1,nil)
	if not (b1 or b2) then return end
	local op=Duel.SelectEffect(tp,
		{b0,aux.Stringid(id,1)},
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	--Level up
	if op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=xg:Select(tp,1,1,nil)
		if #g>0 then
			local lv=Effect.CreateEffect(e:GetHandler())
			lv:SetType(EFFECT_TYPE_SINGLE)
			lv:SetCode(EFFECT_UPDATE_LEVEL)
			lv:SetValue(3)
			lv:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
			g:GetFirst():RegisterEffect(lv)
		end
	--Bannissez 1 carte sur le terrain
	elseif op==3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=rg:Select(tp,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g,true)
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
end

function s.cacon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return tc:IsControler(tp) and tc:IsRace(RACE_SPELLCASTER) and tc:CanChainAttack() and tc:IsStatus(STATUS_OPPO_BATTLE)
end
function s.caop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChainAttack()
end