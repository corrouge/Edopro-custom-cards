--Électro-Assaut
--Corrouge
local s,id=GetID()
function s.initial_effect(c)
	--Ativez 1 des effets
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMING_BATTLE_START|TIMING_BATTLE_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={SET_WATT}
s.listed_names={id}

function s.athfilter(c)
	return c:IsSetCard(SET_WATT) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return (#g==0 or (#g>0 and g:FilterCount(aux.FaceupFilter(Card.IsRace,RACE_THUNDER),nil)==#g))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local op=e:GetLabel()
		if op==1 or not (chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE)) then return false end
		return (op==2 and s.athfilter(chkc)) or (op==3)
	end
	local b1=Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) 
		and not Duel.HasFlagEffect(tp,id)
	local b2=Duel.IsExistingTarget(s.athfilter,tp,LOCATION_GRAVE,0,1,nil)
		and not Duel.HasFlagEffect(tp,id+1)
	local b3=not Duel.HasFlagEffect(tp,id+2)
	if chk==0 then return b1 or b2 or b3 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{b3,aux.Stringid(id,3)})
	e:SetLabel(op)
	--Annulez les effets d'1 monstre à effet
	if op==1 then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		e:SetCategory(CATEGORY_DISABLE)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
	--Récupérer 1 carte électro du cimetière
	elseif op==2 then
		Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)
		e:SetCategory(CATEGORY_TOHAND)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectTarget(tp,s.athfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
	--Ancient gears
	elseif op==3 then
		Duel.RegisterFlagEffect(tp,id+2,RESET_PHASE|PHASE_END,0,1)
		e:SetProperty(0)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	if op==1 then
		--Annulez les effets d'1 monstre à effet
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
		end
	elseif op==2 then
		--Récupérer 1 carte électro du cimetière
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			Duel.SendtoHand(tc,tp,REASON_EFFECT)
		end
	elseif op==3 then
		--Ancient gears
		local ge1=Effect.CreateEffect(e:GetHandler())
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		ge1:SetCode(EFFECT_CANNOT_ACTIVATE)
		ge1:SetTargetRange(0,1)
		ge1:SetValue(function(e,re,tp) return re:IsHasType(EFFECT_TYPE_ACTIVATE) end)
		ge1:SetCondition(s.actcon)
		ge1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(ge1,tp)
		aux.RegisterClientHint(c,0,tp,1,0,aux.Stringid(id,4))
		--Texte
		--local ge2=Effect.CreateEffect(e:GetHandler())
		--ge2:SetDescription(aux.Stringid(id,4))
		--ge2:SetType(EFFECT_TYPE_FIELD)
		--ge2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		--ge2:SetTargetRange(1,0)
		--ge2:SetReset(RESET_PHASE+PHASE_END)
		--Duel.RegisterEffect(ge2,tp)
	end
end
function s.actcon(e)
	local tc=Duel.GetAttacker()
	local tp=e:GetHandlerPlayer()
	return tc and tc:IsControler(tp) and tc:IsSetCard(SET_WATT)
end

