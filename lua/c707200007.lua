--Retour dans le passé
--Scripted by Corrouge
local s,id=GetID()
function s.initial_effect(c)
	--Recycle des cartes
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={id,25343280,31076103,4081094,78697395}

function s.tdfilter(c)
	return (c:IsCode(25343280) or c:IsCode(31076103) or c:IsCode(4081094) or c:IsCode(78697395)) and c:IsAbleToDeck()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE|LOCATION_HAND|LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE|LOCATION_HAND|LOCATION_REMOVED,0,nil)
	if #sg==0 then return end
	local rg=aux.SelectUnselectGroup(sg,e,tp,1,4,aux.dncheck,1,tp,HINTMSG_TODECK)
	if #rg>0 then
		local ct=Duel.SendtoDeck(rg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		if ct==0 then return end
		if ct>1 then Duel.SortDeckbottom(tp,tp,ct) end
		Duel.BreakEffect()
		Duel.Draw(tp,ct,REASON_EFFECT)
		--Ne peut pas invoquer spécialement de monstres
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end