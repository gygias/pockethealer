//
//  PriestSpell.m
//  heal drudge
//
//  Created by david on 1/27/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "Logging.h"

#import "PriestSpell.h"

#import "DivineAegisEffect.h"
#import "ArchangelEffect.h"
#import "EvangelismEffect.h"

@implementation PriestSpell

- (void)handleHitWithModifier:(EventModifier *)modifier
{
    // TODO does it matter if DA is applied before or after the rest of "handling hit"?
    [super handleHitWithModifier:modifier];
    
    if ( ! modifier.crit )
        return;
    
    // apply divine aegis
    if ( [self.caster.hdClass isEqual:[HDClass discPriest]] )
    {
        // TODO does DA also proc off of absorbs?
        NSNumber *effectiveHealing = ( self.isChanneled || self.isPeriodic ) ? self.periodicHeal : self.healing;
        if ( effectiveHealing )
        {
            DivineAegisEffect *da = [PriestSpell _divineAegisForEntity:self.target];
            NSNumber *effectiveAbsorb = [DivineAegisEffect absorbWithExistingAbsorb:da.absorb healing:effectiveHealing masteryRating:self.caster.masteryRating sourceMaxHealth:self.caster.health];
            if ( ! da )
            {
                da = [DivineAegisEffect new];
                [self.target addStatusEffect:da source:self.caster];
            } else
                PHLog(self,@"%@'s existing %@ is going from %@ to %@!",self.target,da.absorb,da.absorb,effectiveAbsorb);
            da.absorb = effectiveAbsorb;
        }
    }
}

+ (DivineAegisEffect *)_divineAegisForEntity:(Entity *)entity
{
    __block DivineAegisEffect *theEffect = nil;
    [entity.statusEffects enumerateObjectsUsingBlock:^(Effect *obj, NSUInteger idx, BOOL *stop) {
        if ( [obj isKindOfClass:[DivineAegisEffect class]] )
        {
            theEffect = (DivineAegisEffect *)obj;
            *stop = YES;
        }
    }];
    
    return theEffect;
}

+ (ArchangelEffect *)_archangelForEntity:(Entity *)entity
{
    for ( Effect *effect in entity.statusEffects )
    {
        if ( [effect isKindOfClass:[ArchangelEffect class]] )
        {
            return (ArchangelEffect *)effect;
        }
    }
    return nil;
}

+ (EvangelismEffect *)_evangelismForEntity:(Entity *)entity
{
    for ( Effect *effect in entity.statusEffects )
    {
        if ( [effect isKindOfClass:[EvangelismEffect class]] )
        {
            return (EvangelismEffect *)effect;
        }
    }
    return nil;
}


@end
