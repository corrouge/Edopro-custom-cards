--Prima Donna d'un Autre Monde
--Scripted by Corrouge
local s,id=GetID()
local COUNTER_WORM=0xf
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_WORM)
	--Invocation Lien
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2,nil,s.matcheck)
	--Place des Compteurs Ver sur cette carte
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_MSET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.accon1)
	e1:SetOperation(s.acop)
	c:RegisterEffect(e1)
	local e1a=e1:Clone()
	e1a:SetCode(EVENT_SSET)
	c:RegisterEffect(e1a)
	local e1b=e1:Clone()
	e1b:SetCode(EVENT_CHANGE_POS)
	e1b:SetCondition(s.accon2)
	c:RegisterEffect(e1b)
	local e1c=e1:Clone()
	e1c:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1c:SetCondition(s.accon3)
	c:RegisterEffect(e1c)
	--Gagne 100 ATK pour chaque Compteur Ver
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	--Remplace sa destruction
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.reptg)
	c:RegisterEffect(e3)
	--Détruit 1 carte contrôlée par votre adversaire
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
	e4:SetCost(s.descost)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
	local e4a=e4:Clone()
	e4a:SetType(EFFECT_TYPE_QUICK_O)
	e4a:SetCode(EVENT_FREE_CHAIN)
	e4a:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e4a:SetCondition(s.descon)
	c:RegisterEffect(e4a)
end
s.listed_names={id}
s.counter_place_list={COUNTER_WORM}
function s.matcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsType,1,nil,TYPE_FLIP,lc,sumtype,tp)
end


function s.atkval(e,c)
	return c:GetCounter(COUNTER_WORM)*100
end


function s.accon1(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(1)
	return eg:GetFirst()
end
function s.filter2(c,tp)
	return (c:GetPreviousPosition()&POS_FACEUP)~=0 and (c:GetPosition()&POS_FACEDOWN)~=0
end
function s.accon2(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(s.filter2,nil)
	e:SetLabel(ct)
	return ct>0
end
function s.filter3(c,tp)
	return c:IsFacedown()
end
function s.accon3(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(s.filter3,nil)
	e:SetLabel(ct)
	return ct>0
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	if ct>0 then
		e:GetHandler():AddCounter(COUNTER_WORM,ct,true)
	end
end


function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and Duel.IsCanRemoveCounter(tp,1,0,COUNTER_WORM,1,REASON_EFFECT) end
	if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		return Duel.RemoveCounter(tp,1,0,COUNTER_WORM,1,REASON_EFFECT)
	else return false end
end


function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase() and e:GetHandler():GetCounter(COUNTER_WORM)>=3
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,COUNTER_WORM,2,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,COUNTER_WORM,2,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end