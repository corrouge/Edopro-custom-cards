--Mort, Demoiselle de Fortune
--Scripted by Corrouge
local s,id=GetID()
function s.initial_effect(c)
	--ATK/DEF = Niveau * 400
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(s.value)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e2)
	--Augmentez le niveau de cette carte de 3
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.lvcon)
	e3:SetCost(s.lvcost)
	e3:SetOperation(s.levelup)
	c:RegisterEffect(e3)
	--Bannissez 1 monstre Magicien depuis votre deck
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SEARCH+CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_REMOVE)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.retg)
	e4:SetOperation(s.reop)
	c:RegisterEffect(e4)
end
s.listed_names={id}
s.listed_series={0x31}

function s.value(e,c)
	return c:GetLevel()*400
end

function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase() and e:GetHandler():GetLevel()<12
end
function s.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end
function s.changefilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
function s.levelup(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(3)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e1)
	local g=Duel.GetMatchingGroup(s.changefilter,tp,0,LOCATION_MZONE,nil)
	--Changez 1 monstre face recto contrôlé par votre adversaire en position de défense face verso
	if c:GetLevel()>=6 and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local sg=g:Select(tp,1,1,nil)
		Duel.HintSelection(sg)
		local tc=sg:GetFirst()
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end

function s.refilter(c)
	return c:IsMonster() and c:IsRace(RACE_SPELLCASTER) and c:IsAbleToRemove()
end
function s.retg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.refilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function s.reop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.refilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end