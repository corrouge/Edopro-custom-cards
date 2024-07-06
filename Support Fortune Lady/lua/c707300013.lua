--Fin, Demoiselle de Fortune
--Scripted by Corrouge
local s,id=GetID()
function s.initial_effect(c)
	--Invocation synchro
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_DARK),1,1,Synchro.NonTunerEx(Card.IsRace,RACE_SPELLCASTER),1,99)
	c:EnableReviveLimit()
	--ATK/DEF = Niveau * 400
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetCondition(s.lvcon(1))
	e1:SetValue(s.value)
	c:RegisterEffect(e1)
	local e1a=e1:Clone()
	e1a:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e1a)
	--Son contrôle ne peut pas changer
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
	e2:SetCondition(s.lvcon(2))
	c:RegisterEffect(e2)
	--Ne peut pas être sacrifié
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UNRELEASABLE_SUM)
	e3:SetCondition(s.lvcon(3))
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e3a=e3:Clone()
	e3a:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e3a)
	--Bannissez la carte
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetCategory(CATEGORY_REMOVE)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_CHAINING)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(EFFECT_COUNT_CODE_CHAIN)
	e6:SetCondition(s.lvupcon)
	e6:SetTarget(s.lvuptg)
	e6:SetOperation(s.levelup)
	c:RegisterEffect(e6)
	--Bannissez toutes les cartes dans le cimetière de votre adversaire
	local e12=Effect.CreateEffect(c)
	e12:SetDescription(aux.Stringid(id,0))
	e12:SetCategory(CATEGORY_REMOVE)
	e12:SetType(EFFECT_TYPE_QUICK_O)
	e12:SetCode(EVENT_FREE_CHAIN)
	e12:SetRange(LOCATION_MZONE)
	e12:SetHintTiming(0,TIMING_END_PHASE)
	e12:SetCondition(s.lvcon(12))
	e12:SetCost(aux.bfgcost)
	e12:SetTarget(s.rmtg)
	e12:SetOperation(s.rmop)
	c:RegisterEffect(e12)
end
s.listed_names={id}
s.listed_series={SET_FORTUNE_LADY}

function s.lvcon(level)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		return c:IsLevelAbove(level)
	end
end

function s.value(e,c)
	return c:GetLevel()*400
end

function s.lvupcon(e,tp,eg,ep,ev,re,r,rp)
	return s.lvcon(6) 
		and re:GetHandler():IsOnField() and not re:GetHandler():IsCode(id) and (re:IsActiveType(TYPE_MONSTER)
		or (re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and not re:IsHasType(EFFECT_TYPE_ACTIVATE)))
end
function s.lvuptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsAbleToRemove() end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
end
function s.levelup(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=re:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or not re:GetHandler():IsRelateToEffect(re) then return end
	--Bannissez la carte
	if Duel.Remove(eg,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY) then
		--Renvoyez la carte sur le terrain
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(eg:GetFirst())
		e1:SetCountLimit(1)
		e1:SetOperation(s.retop)
		Duel.RegisterEffect(e1,tp)
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e1)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)>0 then return end
	Duel.ReturnToField(e:GetLabelObject())
end

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,nil)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	end
end