//
//  ARCAvailability.h
//  BasicDemo
//
//  Created by Nicolas VERINAUD on 11/08/13.
//  Copyright (c) 2013 Nicolas VERINAUD. All rights reserved.
//

#ifndef BasicDemo_ARCAvailability_h
#define BasicDemo_ARCAvailability_h

#ifdef __has_feature
	#define OBJC_ARC_ENABLED __has_feature(objc_arc)
#else
	#define OBJC_ARC_ENABLED 0
#endif

#endif
