--Combat sans fin de la nébuleuse W
--Scripted by Corrouge
local s,id=GetID()
local SET_W_Nebula=0x701
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	--Activation
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Invoquez Spécialement 1 monstre Reptile "Ver" depuis votre cimetière en position de défense face verso
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
	e1:SetCondition(function(_,tp,_,_,_,re,_,rp) return rp==1-tp and re:IsActiveType(TYPE_MONSTER) end)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Tant que vous contrôlez 5 monstres face verso, annulez les effets de toutes les cartes face recto sur le Terrain
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.disable)
	e2:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	c:RegisterEffect(e2)
	--Previens sa destruction
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTarget(s.desreptg)
	e3:SetOperation(s.desrepop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_WORM,SET_W_Nebula}
s.listed_names={id}

function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_WORM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if sc then
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
	end
end

function s.condition(e,c)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_MZONE,0,5,nil)
end
function s.disable(e,c)
	return not c:IsCode(id) and c:IsType(TYPE_EFFECT|TYPE_SPELL|TYPE_TRAP) or (c:GetOriginalType()&TYPE_EFFECT)==TYPE_EFFECT 
end

function s.repfilter(c)
	return c:IsFacedown() and c:IsAbleToGrave()
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and c:IsOnField() and c:IsFaceup()
		and Duel.IsExistingMatchingCard(s.repfilter,tp,LOCATION_ONFIELD,0,1,c,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
	local g=Duel.SelectMatchingCard(tp,s.repfilter,tp,LOCATION_ONFIELD,0,1,1,c,e)
	e:SetLabelObject(g:GetFirst())
	Duel.HintSelection(g)
	g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
	return true
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end