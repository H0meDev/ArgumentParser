//
//  FSArgumentParser.m
//  FSArgumentParser
//
//  Created by Christopher Miller on 2/23/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSArgumentParser.h"
#import "FSArgumentPackage.h"
#import "FSArgumentSignature.h"

/*NSString * kFSAPErrorDomain = @"net.fsdev.argument_parser";

const struct FSAPErrorDictKeys FSAPErrorDictKeys = {
    .ImpureSignatureObject = @"impureSignatureObject",
    .ImpureSignatureLocation = @"impureSignatureLocation",
    
    .OverlappingArgumentName = @"overlappingArgumentName",
    .OverlappingArgumentSignature1 = @"overlappingArgumentSignature1",
    .OverlappingArgumentSignature2 = @"overlappingArgumentSignature2",
    
    .TooManyOfThisSignature = @"tooManyOfThisSignature",
    .CountOfTooManySignatures = @"countOfTooManySignatures",
    
    .MissingTheseSignatures = @"missingTheseSignatures",
    
    .ArgumentOfTypeMissingValue = @"argumentOfTypeMissingValue",
    
    .UnknownSignature = @"unknownSignature"
};

@interface FSArgumentPackage (__nice_constructor__)
+ (id)argumentPackageWithFlags:(NSDictionary *)flags namedArguments:(NSDictionary *)namedArguments unnamedArguments:(NSArray *)unnamedArguments;
@end

void IncrementCountOfKeyInDictionary(NSMutableDictionary *, id); // used to increment flag counts
NSUInteger CountOfKeyInDictionary(NSDictionary *, id); // used to find the count; just an easy convenience method*/

@implementation FSArgumentParser

/* This is a scary function which scans the argument array for items that can be extracted using the provided signatures. The overall process is:
 *
 * 1. Scan the signature array for purity. If there's an object which doesn't implement FSArgumentSignature, then an error is thrown.
 * 2. Scan the signature array for conflicting signatures. This means that if we have two different signature objects which want the same flag, we'll be able to throw an error.
 * 3. Sort the signatures into two groups: flags and named arguments. This makes lookup during scanning slightly easier.
 * 4. Iterate over the arguments:
 *  4.1. Take the first argument.
 *  4.2. If it's a flag.... (eg. -f and NOT --f), iterate over each flag in the flag group (eg. -cfg gets iterations for c, f, and g):
 *      4.2.1. If that flag corresponds to an actual flag:
 *          4.2.1.1. Increment that signature's flag count
 *          4.2.1.2. If that signature's flag count is greater than 1 AND that signature doesn't allow multiple invocations, throw an error
 *      4.2.2. Else, that flag corresponds to a named argument:
 *          4.2.2.1. Pop forward on the argument array until an argument matches the isntSignature regex.
 *          4.2.2.2. Take that argument. It's now the value of the flagged argument.
 *          4.2.2.3. If that signature's flag doesn't allow multiple invocations, and there's more than one value in that argument, throw an error
 *  4.3. Else if it's a named argument.... (eg. --f and NOT -f):
 *      4.3.1. If that argument corresponds to a flag:
 *          4.3.1.1. Increment that signature's flag count
 *          4.3.1.2. If that signature's flag count is greater than 1 AND that signature doesn't allow multiple invocations, throw an error
 *      4.3.2. Else, that flag corresponds to a named argument:
 *          4.3.2.1. Pop forward on the argument array until an argument matches the isntSignature regex
 *          4.3.2.2. Take that argument. It's now the value of the flagged argument.
 *          4.3.2.3. If that signature's flag doesn't allow multiple invocations, AND there's more than one value in that argument, throw an error
 *  4.4. Finally, it's just a regular string. Append it to the unnamed arguments array.
 * 5. Collect all found arguments
 * 6. If any required argument isn't in the found arguments, throw an error
 * 7. If any exclusive argument is found (an argument which invalidates the "if any required argument isn't found" bit) then don't throw that error. (spaghetti thinking, but not actually spaghetti code).
 * 8. Coalesce the found elements into an FSArgumentPackage *
 * 9. Return the result
 */
/*+ (FSArgumentPackage *)parseArguments:(NSArray *)_args withSignatures:(NSArray *)signatures error:(__autoreleasing NSError **)error
{
    NSMutableArray * args = [_args mutableCopy];*/
    
    /* check for purity in signature array */ // see step 1
    /*[signatures enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[FSArgumentSignature class]]) {
            *error = [NSError errorWithDomain:kFSAPErrorDomain code:ImpureSignatureArray userInfo:[NSDictionary dictionaryWithObjectsAndKeys:obj, FSAPErrorDictKeys.ImpureSignatureObject,
                                                                                                   [NSNumber numberWithUnsignedInteger:idx], FSAPErrorDictKeys.ImpureSignatureLocation, nil]];
            *stop = YES;
        }
    }]; if (*error) return nil;*/
    
    /* check for conflicting signatures */ // see step 2 
    /*[signatures enumerateObjectsUsingBlock:^(FSArgumentSignature * signature, NSUInteger signature_idx, BOOL *signature_stop) {*/
	
	/* scan the shortnames for conflicts */
	
        /*[signatures enumerateObjectsUsingBlock:^(FSArgumentSignature * signature2, NSUInteger signature2_idx, BOOL *signature2_stop) {
            if (signature2==signature) return; // duh they're going to match!
            NSMutableCharacterSet * signature_shortnames = [signature.shortNames mutableCopy];
            [signature_shortnames formIntersectionWithCharacterSet:signature2.shortNames];
            BOOL shortname_conflict=NO;
            for (unichar t = 0;
                 t < 256;
                 ++t) {
                if ([signature_shortnames characterIsMember:t]) {
                    shortname_conflict = YES;
                    break;
                }
            }
            if (shortname_conflict) {
                *signature2_stop = YES;
                *signature_stop = YES;
                *error = [NSError errorWithDomain:kFSAPErrorDomain code:OverlappingArgument userInfo:[NSDictionary dictionaryWithObjectsAndKeys:signature_shortnames, FSAPErrorDictKeys.OverlappingArgumentName,
                                                                                                      signature, FSAPErrorDictKeys.OverlappingArgumentSignature1,
                                                                                                      signature2, FSAPErrorDictKeys.OverlappingArgumentSignature2, nil]];
            }
        }];
        if (*signature_stop==YES) return; */// just die now

	/* scan the long names for conflicts */

        /*[signature.longNames enumerateObjectsUsingBlock:^(NSString * longName, NSUInteger longName_idx, BOOL *longName_stop) {
            [signatures enumerateObjectsUsingBlock:^(FSArgumentSignature * signature2, NSUInteger signature2_idx, BOOL *signature2_stop) {
                if (signature==signature2) return; // duh they're going to match!
                if ([signature2.longNames containsObject:longName]) {
                    // stop
                    *signature_stop = YES;
                    *longName_stop = YES;
                    *signature2_stop = YES;
                    *error = [NSError errorWithDomain:kFSAPErrorDomain code:OverlappingArgument userInfo:[NSDictionary dictionaryWithObjectsAndKeys:longName, FSAPErrorDictKeys.OverlappingArgumentName,
                                                                                                          signature, FSAPErrorDictKeys.OverlappingArgumentSignature1,
                                                                                                          signature2, FSAPErrorDictKeys.OverlappingArgumentSignature2, nil]];
                }
            }];
        }];
    }]; if (*error) return nil;*/
    
    // these little darlings get to be copied over into the final argument package
//    NSMutableDictionary * flags = [[NSMutableDictionary alloc] init]; /* These are all flags that have been set. It's empty now, but gets populated with false values later. */
//    NSMutableDictionary * namedArguments = [[NSMutableDictionary alloc] init]; /* These are all named arguments. It's supposed to be empty. */
//    NSMutableArray * unnamedArguments = [[NSMutableArray alloc] init]; /* Unnamed arguments are essentially everything that is left over after the detected arguments are found.
//                                                                        * They will be in the order of how they were originally found in the array. */
    /* the following are sorted bits from the signatures array */
//    NSMutableSet * flagSignatures = [[NSMutableSet alloc] init]; // all the flag signatures
//    NSMutableCharacterSet * flagCharacters = [[NSMutableCharacterSet alloc] init]; // all the flag characters. If the character is in this set, congrats! it's a flag
//    NSMutableArray * flagNames = [[NSMutableArray alloc] init]; // All the flag names, eg. names that correspond to a flag signature. If the string is in this array, congrats! it's a flag
//    NSMutableSet * notFlagSignatures = [[NSMutableSet alloc] init]; // if it ain't a flag, then it's in this signature array.
    // actually perform the sorting. see step 3
    /*[signatures enumerateObjectsUsingBlock:^(FSArgumentSignature * obj, NSUInteger idx, BOOL *stop) {
        if (obj.isFlag) {
            [flagSignatures addObject:obj];
            [flagCharacters formUnionWithCharacterSet:obj.shortNames];
            [flagNames addObjectsFromArray:obj.longNames];
            [flags setObject:[NSNumber numberWithUnsignedInteger:0] forKey:obj]; */// initialize the value of the flag to false.
            /* a note on implementation decisions:
             * 
             * I have chosen it such that every single flag shall be false. If the flag does not appear at all, it's false. It used to be in a previous iteration that it would be nil, which is a very bad idea. it created obnoxious nil checks which had to be reinterpreted as false, etc. it was just bad.
             *
             * this is a lot better.
             */
        /*}
        else [notFlagSignatures addObject:obj]; // seems obvious, right?
    }];*/
    
    // these are some regexen that define whether or not a given string (from the arg array) is a flag, named argument, or isn't a value.

    // Matches -anything, but NOT --anything.
    /*NSRegularExpression * flagDetector = [NSRegularExpression regularExpressionWithPattern:@"^[\\-][^\\-]*$" options:0 error:error];
    if (*error) return nil; // asplode if my regexen fails
    // Match --anything, but NOT -anything. Ain't that spiffy?
    NSRegularExpression * namedArgumentDetector = [NSRegularExpression regularExpressionWithPattern:@"^[\\-]{2}.*$" options:0 error:error];
    if (*error) return nil;*/
    /* This is a general catch-all that signifies that something ISN'T a value and should be ignored by the value grabber.
     *
     * In explainum: consider the following invocation:
     *
     *   foo -cfg --no-bar file.txt
     *
     * Imagine for a moment that the -f is a named argument. The parser is going to want to pop forward and grab '--no-bar' as the value. HOWEVER, because --no-bar doesn't match the isntValueDetector, it's excluded. So the parser will move forward again to file.txt (which makes more sense, right?) Just nod your head, because it makes a lot more sense.
     *
     * In the event that a stupid invocation is given, like, say, this:
     *
     *   foo -cfg --no-bar
     *
     * The scanner will perform reliably and tell you that there is no value given to the -f argument. As a note, how would you pass in a file that begins with a dash?
     *
     *   foo -cfg ./--no-bar.txt
     *
     * I know, smart-ass answer, but hey... it's what you do.
     */
    /*NSRegularExpression * isntValueDetector = [NSRegularExpression regularExpressionWithPattern:@"^\\-" options:0 error:error];
    if (*error) return nil;*/
    
    /* this begins the biggest piece of evil ever. comments have been added for entertainment purposes */
    /*while (0<[args count]) { // we use a wonky iteration because we're tearing elements out of the array during iteration. Thus we can't use fast enumeration. Once an element is parsed (sorted into a bucket, either a flag increment, named argument value, or as an unnamed argument) it's removed from the source array which means that it's done. Gone. Boom. Parsed. When everything is gone (0==[args count]) then it's considered parsed. ¿Comprendé? Anyway, see step 4

        NSString * arg = [args objectAtIndex:0]; // this is the root arg we'll be working with this iteration. We may pull other args later. See step 4.1
        [args removeObjectAtIndex:0];

        if (0<[flagDetector numberOfMatchesInString:arg options:0 range:NSMakeRange(0, [arg length])]) {*/ // if this is a flag, eg. a -f instead of a --file. see step 4.2

            /* Because flags can have many bretheren and sisteren in their invocations (eg. -cfg is equivalent to -c -f -g) we need to treat each flag individually. */

            /*for (NSUInteger i = 1; // starting at 1 ignores the prefixed 
                 i < [arg length];
                 ++i) { // iteration, see step 4.2

                unichar c = [arg characterAtIndex:i];

                if ([flagCharacters characterIsMember:c]) { // This detects whether this is a flag (a boolean or counted, non-capturing signature). see step 4.2.1
                    FSArgumentSignature * as = [[flagSignatures filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(FSArgumentSignature * evaluatedObject, NSDictionary *bindings) {
                        if ([evaluatedObject.shortNames characterIsMember:c]) return YES;
                        else return NO;
                    }]] anyObject]; // grab the specific flag using the filter predicate.
                    if (!as) { // if there ain't no flag throw an error (numerically impossible, but it could happen if there's a memory leak or some other kind of inconsistency)
                        *error = [NSError errorWithDomain:kFSAPErrorDomain code:UnknownArgument userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithChar:c] forKey:FSAPErrorDictKeys.UnknownSignature]];
                        return nil;
                    }

                    // increment the count for this flag
                    IncrementCountOfKeyInDictionary(flags, as); // step 4.2.1.1
                    if (!as.isMultipleAllowed&&CountOfKeyInDictionary(flags, as)>1) { // step 4.2.1.2
                        *error = [NSError errorWithDomain:kFSAPErrorDomain code:TooManySignatures userInfo:[NSDictionary dictionaryWithObject:as forKey:FSAPErrorDictKeys.TooManyOfThisSignature]];
                        return nil;
                    }
                } else { // it's a named argument. step 4.2.2
                    // same idea as before
                    FSArgumentSignature * as = [[notFlagSignatures filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(FSArgumentSignature * evaluatedObject, NSDictionary *bindings) {
                        if ([evaluatedObject.shortNames characterIsMember:c]) return YES;
                        else return NO;
                    }]] anyObject];
                    if (!as) {
                        *error = [NSError errorWithDomain:kFSAPErrorDomain code:UnknownArgument userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithChar:c] forKey:FSAPErrorDictKeys.UnknownSignature]];
                        return nil;
                    }

                    // scan for the location of the value in the arguments array. step 4.2.2.1
                    __block NSUInteger valueLocation=NSNotFound;
                    [args enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL *stop) {
                        if ([isntValueDetector numberOfMatchesInString:obj options:0 range:NSMakeRange(0, [obj length])]==0) {
                            valueLocation = idx;
                            *stop = YES;
                        }
                    }];
                    if (0==[args count]||valueLocation==NSNotFound) {
                        *error = [NSError errorWithDomain:kFSAPErrorDomain code:ArgumentMissingValue userInfo:[NSDictionary dictionaryWithObject:as forKey:FSAPErrorDictKeys.ArgumentOfTypeMissingValue]];
                        return nil;
                    }
                    id value = [namedArguments objectForKey:as]; // we now has the argument
                    if (value&&!as.isMultipleAllowed) { // step 4.2.2.3
                        *error = [NSError errorWithDomain:kFSAPErrorDomain code:TooManySignatures userInfo:[NSDictionary dictionaryWithObject:as forKey:FSAPErrorDictKeys.TooManyOfThisSignature]];
                        return nil;
                    }
                    if (!value&&as.isMultipleAllowed) value = [NSMutableArray array];
                    // step 4.2.2.2
                    if (as.isMultipleAllowed) [value addObject:[args objectAtIndex:valueLocation]];
                    else value = [args objectAtIndex:valueLocation];

                    [namedArguments setObject:value forKey:as]; // set the args back, if necessary
                    [args removeObjectAtIndex:valueLocation]; // remove the value from the source array so it's not interpreted again
                }
            }
        } else if (0<[namedArgumentDetector numberOfMatchesInString:arg options:0 range:NSMakeRange(0, [arg length])]) { // step 4.3
            NSMutableString * mutable_arg = [arg mutableCopy];
            // chop off the first two dashes
            [mutable_arg deleteCharactersInRange:NSMakeRange(0, 2)];
            if ([flagNames containsObject:mutable_arg]) { // step 4.3.1
                // just a flag
                FSArgumentSignature * as = [[flagSignatures filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(FSArgumentSignature * evaluatedObject, NSDictionary *bindings) {
                    if ([evaluatedObject.longNames containsObject:mutable_arg]) return YES;
                    else return NO;
                }]] anyObject];
                if (!as) {
                    *error = [NSError errorWithDomain:kFSAPErrorDomain code:UnknownArgument userInfo:[NSDictionary dictionaryWithObject:mutable_arg forKey:FSAPErrorDictKeys.UnknownSignature]];
                    return nil;
                }

                // increment the count for this flag
                IncrementCountOfKeyInDictionary(flags, as); // step 4.3.1.1
                if (!as.isMultipleAllowed&&CountOfKeyInDictionary(flags, as)>1) { // step 4.3.1.2
                    *error = [NSError errorWithDomain:kFSAPErrorDomain code:TooManySignatures userInfo:[NSDictionary dictionaryWithObject:as forKey:FSAPErrorDictKeys.TooManyOfThisSignature]];
                    return nil;
                }
            } else { // it's a named argument, step 4.3.2
                FSArgumentSignature * as = [[notFlagSignatures filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(FSArgumentSignature * evaluatedObject, NSDictionary *bindings) {
                    if ([evaluatedObject.longNames containsObject:mutable_arg]) return YES;
                    else return NO;
                }]] anyObject];
                if (!as) {
                    *error = [NSError errorWithDomain:kFSAPErrorDomain code:UnknownArgument userInfo:[NSDictionary dictionaryWithObject:mutable_arg forKey:FSAPErrorDictKeys.UnknownSignature]];
                    return nil;
                }
                // step 4.3.2.1
                __block NSUInteger valueLocation = NSNotFound;
                [args enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL *stop) {
                    if ([isntValueDetector numberOfMatchesInString:obj options:0 range:NSMakeRange(0, [obj length])]==0) {
                        valueLocation = idx;
                        *stop = YES;
                    }
                }];
                if (0==[args count]||valueLocation==NSNotFound) {
                    *error = [NSError errorWithDomain:kFSAPErrorDomain code:ArgumentMissingValue userInfo:[NSDictionary dictionaryWithObject:as forKey:FSAPErrorDictKeys.ArgumentOfTypeMissingValue]];
                    return nil;
                }
                id value = [namedArguments objectForKey:as];
                if (value&&!as.isMultipleAllowed) { // step 4.3.2.3
                    *error = [NSError errorWithDomain:kFSAPErrorDomain code:TooManySignatures userInfo:[NSDictionary dictionaryWithObject:as forKey:FSAPErrorDictKeys.TooManyOfThisSignature]];
                    return nil;
                }
                if (!value&&as.isMultipleAllowed) value = [NSMutableArray array];

                // step 4.3.2.2
                if (as.isMultipleAllowed) [value addObject:[args objectAtIndex:valueLocation]];
                else value = [args objectAtIndex:valueLocation];

                [namedArguments setObject:value forKey:as];
                [args removeObjectAtIndex:valueLocation];
            }
        } else { // unnamed arg; step 4.4
            [unnamedArguments addObject:arg];
        }
    }
   
    // step 5 
    NSMutableArray * allFoundArguments = [[NSMutableArray alloc] initWithArray:[flags allKeys]];
    [allFoundArguments addObjectsFromArray:[namedArguments allKeys]];

    // step 6
    NSMutableArray * allRequiredSignatures = [NSMutableArray arrayWithArray:[signatures filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(FSArgumentSignature * evaluatedObject, NSDictionary *bindings) {        
        return evaluatedObject.isRequired && ![allFoundArguments containsObject:evaluatedObject];
    }]]];
    
    // step 8
    FSArgumentPackage * pkg = [FSArgumentPackage argumentPackageWithFlags:[flags copy] namedArguments:[namedArguments copy] unnamedArguments:[unnamedArguments copy]];

    // check for an exclusive signature, step 7
    NSArray * allExclusiveArguments = [signatures filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(FSArgumentSignature * signature, NSDictionary *bindings) {
        return [signature isExclusive]==YES;
    }]];

    BOOL hasExclusiveArgument = NO;
    for (FSArgumentSignature * signature in allExclusiveArguments)
        if ([pkg boolValueOfFlag:signature]) {
            hasExclusiveArgument = YES;
            break;
        }
    
    if (0<[allRequiredSignatures count]&&!hasExclusiveArgument) {
        *error = [NSError errorWithDomain:kFSAPErrorDomain code:MissingSignatures userInfo:[NSDictionary dictionaryWithObject:allRequiredSignatures forKey:FSAPErrorDictKeys.MissingTheseSignatures]];
        return pkg;
    }
    
    return pkg; */ // step 9
//}

@end
/*
@implementation FSArgumentPackage (__nice_constructor__)
+ (id)argumentPackageWithFlags:(NSDictionary *)flags namedArguments:(NSDictionary *)namedArguments unnamedArguments:(NSArray *)unnamedArguments
{
    FSArgumentPackage * toReturn = [[FSArgumentPackage alloc] init];
    if (!toReturn) return nil;
    toReturn.flags = flags;
    toReturn.namedArguments = namedArguments;
    toReturn.unnamedArguments = unnamedArguments;
    return toReturn;
}
@end

void IncrementCountOfKeyInDictionary(NSMutableDictionary * dictionary, id key)
{
    NSNumber * number = [dictionary objectForKey:key];
    NSCAssert(number!=nil, @"No value for %@, which is the old model. Try and do better next time!", key); // just make sure it's there; used to be an initialize to zero, but I'd rather be sure that things are being initialized beforehand
    [dictionary setObject:[NSNumber numberWithUnsignedInteger:[number unsignedIntegerValue]+1]
                   forKey:key];
}

NSUInteger CountOfKeyInDictionary(NSDictionary * dict, id key)
{
    NSNumber * number = [dict objectForKey:key];
    if (number) return [number unsignedIntegerValue];
    else return NSNotFound;
}
*/