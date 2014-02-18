'w3action' helps you can develop the application using http connection easily and fastly.

## Usage
### Implementation
```objective-c
// load config plist file 
[[HTTPActionManager sharedInstance] addResourceWithBundle:[NSBundle mainBundle] plistName:@"action"];
    
// execution
[[HTTPActionManager sharedInstance] doAction:@"example-datatype-json" 
	param:nil body:nil header:nil success:^(NSDictionary *result){
	NSLog(@"JSON result -> %@", result);
} error:^(NSError *error){
	NSLog(@"error -> %@", error);
}];
```

### Configuration
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Actions</key>
	<dict>
		<key>example-datatype-json</key>
		<dict>
			<key>url</key>
			<string>https://raw.github.com/pisces/w3action/master/w3action-master/resources/example.json</string>
			<key>method</key>
			<string>GET</string>
			<key>contentType</key>
			<string>application/x-www-form-urlencoded</string>
			<key>dataType</key>
			<string>json</string>
			<key>timeout</key>
			<string>10</string>
			<key>async</key>
			<false/>
		</dict>
		<key>example-datatype-xml</key>
		<dict>
			<key>url</key>
			<string>https://raw.github.com/pisces/w3action/master/w3action-master/resources/example.xml</string>
			<key>method</key>
			<string>GET</string>
			<key>contentType</key>
			<string>application/x-www-form-urlencoded</string>
			<key>dataType</key>
			<string>xml</string>
			<key>timeout</key>
			<string>10</string>
			<key>async</key>
			<false/>
		</dict>
		<key>example-datatype-text</key>
		<dict>
			<key>url</key>
			<string>https://raw.github.com/pisces/w3action/master/w3action-master/resources/example.text</string>
			<key>method</key>
			<string>GET</string>
			<key>contentType</key>
			<string>application/x-www-form-urlencoded</string>
			<key>dataType</key>
			<string>text</string>
			<key>timeout</key>
			<string>10</string>
			<key>async</key>
			<false/>
		</dict>
		<key>example-contenttype-multipart</key>
		<dict>
			<key>url</key>
			<string>https://raw.github.com/pisces/w3action/master/w3action-master/resources/example-multipart.json</string>
			<key>method</key>
			<string>GET</string>
			<key>contentType</key>
			<string>multipart/form-data</string>
			<key>dataType</key>
			<string>json</string>
			<key>timeout</key>
			<string>10</string>
			<key>async</key>
			<false/>
		</dict>
		<key>example-path-param</key>
		<dict>
			<key>url</key>
			<string>https://raw.github.com/pisces/w3action/master/w3action-master/{resourceFolderName}/example.json</string>
			<key>method</key>
			<string>GET</string>
			<key>contentType</key>
			<string>application/x-www-form-urlencoded</string>
			<key>dataType</key>
			<string>json</string>
			<key>timeout</key>
			<string>10</string>
			<key>async</key>
			<false/>
		</dict>
	</dict>
</dict>
</plist>
```

### Sample
#### Data Type JSON
```objective-c
[[HTTPActionManager sharedInstance] doAction:@"example-datatype-json" 
	param:nil body:nil header:nil success:^(NSDictionary *result){
	NSLog(@"JSON result -> %@", result);
} error:^(NSError *error){
	NSLog(@"error -> %@", error);
}];
```

#### Data Type XML
```objective-c
[[HTTPActionManager sharedInstance] doAction:@"example-datatype-xml" 
	param:nil body:nil header:nil success:^(APDocument *result){
	NSLog(@"XML result -> %@", result);
} error:^(NSError *error){
	NSLog(@"error -> %@", error);
}];
```

#### Data Type Text
```objective-c
[[HTTPActionManager sharedInstance] doAction:@"example-datatype-text" 
	param:nil body:nil header:nil success:^(NSString *result){
	NSLog(@"Text result -> %@", result);
} error:^(NSError *error){
	NSLog(@"error -> %@", error);
}];
```

#### Multipart Form Data
```objective-c
UIImage *image = [[UIImage alloc] init];
NSData *imageData = UIImagePNGRepresentation(image);
MultipartFormDataObject *object = [MultipartFormDataObject objectWithFilename:@"sample.png" data:imageData];
    
[[HTTPActionManager sharedInstance] doAction:@"example-contenttype-multipart" 
	param:nil body:object header:nil success:^(NSString *result){
	NSLog(@"JSON result -> %@", result);
} error:^(NSError *error){
	NSLog(@"error -> %@", error);
}];
```

#### URL Path Parameters
```objective-c
NSDictionary *param = @{@"resourceFolderName": @"resources"};
    
[[HTTPActionManager sharedInstance] doAction:@"example-datatype-text" 
	param:nil body:object header:nil success:^(NSString *result){
	NSLog(@"JSON result -> %@", result);
} error:^(NSError *error){
	NSLog(@"error -> %@", error);
}];
```

#### Use directly not use config file
```objective-c
NSDictionary *action = [NSMutableDictionary dictionary];
[action setValue:@"url" forKey:@"https://raw.github.com/pisces/w3action/master/w3action-master/resources/example.json"
[action setValue:@"method" forKey:HTTP_METHOD_POST];
[action setValue:@"contentType" forKey:ContentTypeApplicationJSON];
[action setValue:@"dataType" forKey:DataTypeJSON];
[action setValue:@"timeout" forKey:@"10"];
    
HTTPRequestObject *object = [[HTTPRequestObject alloc] init];
object.action = action;
object.param = @{@"p1": @"easy", @"p2": @"simple"};
    
[[HTTPActionManager sharedInstance] doActionWithRequestObject:object success:^(NSDictionary *result){
	NSLog(@"JSON result -> %@", result);
} error:^(NSError *error){
	NSLog(@"error -> %@", error);
}];
```


## License
Copyright 2013 KH Kim, hh963103@gmail.com
 
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
 
http://www.apache.org/licenses/LICENSE-2.0
 
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
