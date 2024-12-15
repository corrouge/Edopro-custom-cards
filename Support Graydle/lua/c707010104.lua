--Rage Berceau-Gris
--Corrouge
local s,id=GetID()
function s.initial_effect(c)
	--Annulez des effets
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	--invocation speciale
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp) return Duel.IsMainPhase() end)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_GRAYDLE}
s.listed_names={id}

function s.grayfilter(c)
	return (c:IsSetCard(SET_GRAYDLE) or c:IsAttribute(ATTRIBUTE_WATER)) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsNegatable),tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(s.grayfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_ONFIELD+LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,1-tp,0)
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g1=Duel.GetMatchingGroup(s.grayfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,e:GetHandler())
	local g2=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsNegatable),tp,0,LOCATION_ONFIELD,nil)
	if #g1==0 or #g2==0 then return end
	--Destruction
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local sg1=g1:Select(tp,1,#g2,nil)
	if #sg1>0 and Duel.Destroy(sg1,REASON_EFFECT)>0 then
		--Annule les effets
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
		local sg2=g2:Select(tp,#sg1,#sg1,nil)
		for tc in aux.Next(sg2) do
			tc:NegateEffects(c,RESET_PHASE+PHASE_END,true)
		end
	end
end

function s.gyfilter(c,e)
	return c:IsAttackAbove(1) and c:GetOwner()~=e:GetHandlerPlayer()
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.gyfilter(chkc,e) end
	if chk==0 then return Duel.IsExistingTarget(s.gyfilter,tp,LOCATION_MZONE,0,1,e:GetHandler(),e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.gyfilter,tp,LOCATION_MZONE,0,1,1,nil,e)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetAttack()/2)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,g,0,0)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsAttackBelow(0) then return end
	if Duel.Damage(tp,tc:GetAttack()/2,REASON_EFFECT)>0 then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end		
end