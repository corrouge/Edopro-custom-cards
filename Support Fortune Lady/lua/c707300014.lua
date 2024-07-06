--Demoiselle de Fortune et Malheur
--Scripted by Corrouge
local s,id=GetID()
function s.initial_effect(c)
	--Ajoutez 1 Magie/Piège "Demoiselle de fortune" depuis votre deck à votre main
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e1a=e1:Clone()
	e1a:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1a)
	--Manipulation du bannissement
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.rmcost)
	--e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={SET_FORTUNE_LADY}

function s.thfilter(c)
	return c:IsSpellTrap() and c:IsSetCard(SET_FORTUNE_LADY) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.rmfilter(c)
	return c:IsAbleToRemove()
end
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_HAND|LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_HAND|LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil):GetFirst()
	local label=tc:IsLocation(LOCATION_HAND) and 1 or 0
	e:SetLabel(label)
	Duel.Remove(tc,POS_FACEUP,REASON_COST)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local label=e:GetLabel()
	if label==1 then
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,LOCATION_REMOVED)
	end
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local label=e:GetLabel()
	--Ajoutez cette carte à votre main
	if label==1 then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	--renvoyez cette carte dans le cimetière
	elseif label==0 then
		Duel.SendtoGrave(c,REASON_EFFECT+REASON_RETURN)
	end
end