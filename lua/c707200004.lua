--Malédiction du Premier Sarcophage
--Scripted by Corrouge
local s,id=GetID()
function s.initial_effect(c)
	--Activation
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Annule les effets
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.disable)
	e1:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e1)
	--Ajoutez 1 "Premier Sarcophage" ou 1 carte qui le mentionne dans son texte depuis votre cimetière à votre main
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--Acivez cette carte depuis la main
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e3:SetCondition(s.handcon)
	c:RegisterEffect(e3)
	--count
	aux.GlobalCheck(s,function()
		local gc=Effect.CreateEffect(c)
		gc:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		gc:SetCode(EVENT_LEAVE_FIELD)
		gc:SetCondition(s.checkcon)
		gc:SetOperation(s.checkop)
		Duel.RegisterEffect(gc,0)
	end)
end
s.listed_names={id,31076103,25343280}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	--Envoyez cette carte au cimetière
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetOperation(s.sop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
	c:SetTurnCounter(0)
	c:RegisterEffect(e1)
end
function s.sop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==2 then
		Duel.SendtoGrave(c,REASON_RULE)
	end
end

function s.cfilter2(c)
	return not c:IsRace(RACE_ZOMBIE)
end
function s.condition(e,c)
	local tp=e:GetHandler():GetControler()
	local g=Duel.GetMatchingGroup(Card.IsMonster,tp,LOCATION_GRAVE,0,nil)
	return #g>0 and not g:IsExists(s.cfilter2,1,nil)
end
function s.disable(e,c)
	return not c:IsCode(25343280) and (c:IsType(TYPE_EFFECT) or (c:GetOriginalType()&TYPE_EFFECT)==TYPE_EFFECT)
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE)
end
function s.thfilter(c)
	return (c:ListsCode(31076103) or c:IsCode(4081094) or c:IsCode(78697395)) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.handcon(e)
	return Duel.GetFlagEffect(e:GetHandler():GetControler(),id)>0
end
function s.checkcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
function s.checkfilter(c,tp)
	return c:IsCode(31076103) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.checkfilter,1,nil,tp) then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	end
end