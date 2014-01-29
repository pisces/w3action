'w3action' helps you can develop the application using http connection easily and fastly.

## Usage
### Implementation
```
objective-c
// load config plist file 
[[HTTPActionManager sharedInstance] addResourceWithBundle:[NSBundle bundleForClass:[self class]] plistName:@"action"];
    
// execution
[[HTTPActionManager sharedInstance] doAction:@"example-datatype-json" param:nil body:nil header:nil success:^(NSDictionary *result){
        NSLog(@"JSON result -> %@", result);
} error:^(NSError *error){
        NSLog(@"error -> %@", error);
}];
```

### Configuration
```
xml
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
		</dict>
	</dict>
</dict>
</plist>

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
