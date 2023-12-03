--Quatrième Sarcophage Oubliée
--Scripted by Corrouge
local s,id=GetID()
function s.initial_effect(c)
	--Activation
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCost(s.actcost)
	c:RegisterEffect(e0)
	--Invoquez Rituellement Uraeus depuis votre main
	local e1=Ritual.CreateProc(c,RITPROC_GREATER,aux.FilterBoolFunction(Card.IsCode,707200006),nil,aux.Stringid(id,0),nil,nil,nil,nil,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e,tp) return not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsOriginalCode,707200006),tp,LOCATION_MZONE,0,1,nil) end)
	c:RegisterEffect(e1)
	--Ajoutez 1 monstre Zombie depuis votre cimetière
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_names={id,31076103,707200006}

function s.costfilter(c)
	return (c:IsFaceup() or not c:IsOnField()) and c:IsCode(31076103) and c:IsAbleToRemoveAsCost()
end
function s.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE|LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE|LOCATION_ONFIELD,0,1,1,nil)
	Duel.Remove(g,nil,REASON_COST)
end

function s.thfilter(c)
	return c:IsRace(RACE_ZOMBIE) and (c:IsAttack(0) or c:IsDefense(0)) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
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
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.sumlimit(e,c)
	return c:IsCode(e:GetLabel())
end