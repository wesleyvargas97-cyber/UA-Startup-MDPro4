-- U.A. Startup
-- Custom card script for MDPro4 / YGOPro-compatible ocgcore.
local s,id=GetID()
function s.initial_effect(c)
    -- Activate: add 1 "U.A." monster from Deck to hand.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    -- If the opponent Special Summons, you may banish this card from the GY
    -- as cost, then Special Summon 1 "U.A." monster from your GY.
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetCondition(s.spcon)
    e2:SetCost(s.spcost)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

function s.thfilter(c)
    if not c:IsMonster() or not c:IsAbleToHand() then return false end
    -- Some custom MDPro4 databases do not expose the U.A. setcode consistently.
    -- Prefer the archetype code, with a card-name fallback for U.A. monsters.
    local name=c:GetName()
    return c:IsSetCard(0x7a) or string.find(name,"U%.A%.")~=nil
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    -- Do not let a custom database/setcode mismatch make the Spell unclickable.
    -- The operation still searches only for a valid U.A. monster.
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) then
        Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(id,0))
        return
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

function s.spfilter(c,tp)
    return c:IsSetCard(0x7a) and c:IsMonster()
        and c:IsCanBeSpecialSummoned(nil,0,tp,false,false)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return ep==1-tp and eg:IsExists(Card.IsSummonType,1,nil,SUMMON_TYPE_SPECIAL)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToRemoveAsCost() end
    Duel.Remove(c,POS_FACEUP,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc) end
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- Build trigger: package generator was added for MDPro4 1.0.4.
