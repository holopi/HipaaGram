/*
 * Copyright (C) 2013 catalyze.io, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

#import <Foundation/Foundation.h>
#import "Geocode.h"
#import "JSONObject.h"

@interface Address : JSONObject<NSCoding>

@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *addressLine1;
@property (strong, nonatomic) NSString *addressLine2;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSString *zipCode;
@property (strong, nonatomic) NSString *country;
@property (strong, nonatomic) Geocode *geocode;

@end
