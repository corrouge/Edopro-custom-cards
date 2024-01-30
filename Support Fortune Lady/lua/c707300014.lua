--Malheur et Fortune
--Scripted by Corrouge
local s,id=GetID()
function s.initial_effect(c)
	--Ajoutez 1 de vos monstres Magicien banni à votre main
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,1})
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	--Invoquez Spécialement 1 monstre Magicien depuis votre main ou cimetière
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,{id,2})
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_names={id}

function s.rmfilter(c,e,tp)
	return c:IsAbleToRemove() and c:IsCanBeEffectTarget(e)
		and (c:IsControler(1-tp) or (c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)))
end
function s.rmrescon(sg,e,tp,mg)
    return sg:FilterCount(Card.IsControler,nil,tp)==1
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local rg=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_MZONE,LOCATION_SZONE,nil,e,tp)
	if chk==0 then return aux.SelectUnselectGroup(rg,e,tp,2,2,s.rmrescon,0) end
	local g=aux.SelectUnselectGroup(rg,e,tp,2,2,s.rmrescon,1,tp,HINTMSG_REMOVE)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,2,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end

function s.spfilter(c,e,tp,lv)
	return c:IsRace(RACE_SPELLCASTER) and c:IsLevelBelow(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsRace,tp,LOCATION_REMOVED,0,nil,RACE_SPELLCASTER)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0  
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp,#g) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.GetMatchingGroup(Card.IsRace,tp,LOCATION_REMOVED,0,nil,RACE_SPELLCASTER)
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp,#g)
	if #sc>0 then
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
	end
end