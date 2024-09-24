# Trip View Project

## My Approach

I want to start from first principles and begin by defining a set of user stories that reflect the task document. These will define what the app should do for the user and allow us to create test cases, which we can then translate into unit tests within our code.

Overall, I plan to use an **MVVM approach**, and I have chosen to use **SwiftUI with Combine** as these are modern and flexible approaches. This allows us to benefit from reactive programming with a dynamically updating user interface based on data streams, like those from our networking layer or changes in device state, such as connectivity to the internet.

## Tools

I will use the following tools to develop this app:

- **Xcode** – I have chosen to use native code for this project and to code in Swift, and I will make use of Xcode to do this.
- **Postman** – I'll use this to test API responses, parameters, headers, and so on.
- **[QuickType](https://quicktype.io/)** – This is a free tool that allows us to translate JSON responses into Swift Codable Structs. While we will inevitably need to manually alter and adjust what it generates, it still saves us a lot of time in generating our data classes that we can use with JSONDecoder to translate JSON responses back into data locally in our app.
- **Charles** – I use this to audit the network traffic to the API and for testing different HTTP response codes, etc.
- **Illustrator** – In this case, I used this software to pull the SVG information from the Ember website using Chrome DevTools and edit the content to save as the logo in image and PDF formats.

## Sources of Information

### The Prompt Document

This sets out the key objectives of the project from which we can construct User Stories that reflect what we are looking to achieve with the app.

### The Website

On your website, we see an example of a bus tracking map, and I can also identify your brand colors and fonts, allowing me to make use of these in my app.

### A Google Chat

You have provided me with a link to a Google Chat channel. This will allow me to ask any clarifying questions I may have and verify my understanding of the project to ensure that my implementation aligns with your expectations. This demonstrates the importance of communication with a client or project owner, ensuring that effort is expended in the right direction with a given project.

## User Stories

### User Story 1: Display a Bus’s Current Location

As a passenger,  
I want to see a bus’s current location on a live map  
**because** this means I can track where the bus is and how far away it is from me, so I know when I need to be at the stop to be picked up.

### User Story 2: Display Scheduled & Estimated Times at Each Stop

As a passenger,  
I want to see both the scheduled and estimated arrival times for all stops on the bus route  
**so that** I can plan my trip effectively and know when the bus will arrive at each stop.

### User Story 3: Highlight the Next Stop and ETA

As a passenger,  
I want to see the next stop and its estimated arrival time clearly highlighted  
**so that** I can prepare in advance for when I need to get off the bus or get ready to board.

### User Story 4: Show Seat, Wheelchair, and Bicycle Availability

As a passenger,  
I want to know how many seats, wheelchair spots, and bicycle spaces are available on the bus  
**so that** I can decide if I want to board the bus and feel reassured that there is space for me.

### User Story 5: Notify About Route Disruptions or Changes

As a passenger,  
I want to be informed of any route disruptions or stop changes  
**so that** I can adjust my plans if the bus is not stopping where it was originally scheduled to stop.

### User Story 6: Offline Functionality for Last Known Location

As a passenger,  
I want to see the last known location of the bus if I lose connection  
**so that** I can still have some reference of where the bus was last located and estimate its arrival on my own.

### User Story 7: Tap for More Information on Bus or Stop

As a passenger,  
I want to be able to tap on the bus or a stop to view additional information (e.g., bus number, amenities, scheduled time)  
**so that** I can get more details about the bus or stop if I need them.


## The Result

The result is my app consisting of a tab based app, with a "Map" tab which list trips and allows one to tap a trip to see the bus's location.

Tapping the bus brings up a callout view with more information, specifically the next stop and the estimated time to arrive there.

At the bottom of the screen is a button to see the full list of stops and estimated times at each stop.

This details screen also shows the number of seat, wheelchair spots, and bike spots on the bus (which the endpoint gives us).

If there are any errors in the fetching from the endpoint (i.e. HTTP status errors), these will show in a toast view on screen.

This is also true of connectivity issues with the devices connection to broad band.

The user can tap to locate themselves on the map with location permissions requested (and disable the auto location to the bus's position).




## Limitations and Future Improvements

I was time limited on this project and thus ran out of time to implement local storage and caching. 

My plan was to use Realm for this as it's a fast and simple to initialise form of local storage which I am used to working with. 

There are aspects of the code which could benefit from further refactoring. 

We have used a Protocol Oriented Approach in this code allowing for better Mocking in the context of Unit Testing, we haven't had enough time to create all 
the mock objects and test every part of the app, so adding this would be something to add in the future. 

The use of the quotes endpoint is a limiting factor as it doesn't give the same information as some other endpoints, the information coming back
from this endpoint can also be somewhat confusing as it will show information about a linked bus's location even it a trip isn't current. 

The hardcoding of the start end endpoint of the trip for generating quotes was locked in as per the project spec, but it would be 
quite straight forward to implement the selection of a start and endpoint when getting quotes for trips. 

We didn't map all the bus stop points as annotations in this implementation, as I ran out of time to add these back in with my updated code to add the 
bus's location currently.

