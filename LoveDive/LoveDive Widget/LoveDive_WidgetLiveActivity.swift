//
//  LoveDive_WidgetLiveActivity.swift
//  LoveDive Widget
//
//  Created by Nick Liu on 2023/6/29.
//

import ActivityKit
import SwiftUI
import WidgetKit

// MARK: - TimerAttributes

struct TimerAttributes: ActivityAttributes {

  public typealias TimerStatus = ContentState

  public struct ContentState: Codable, Hashable {
    // Dynamic stateful properties about your activity go here!
    var endTime: ClosedRange<Date>
    var progress: CGFloat
  }

  // Fixed non-changing properties about your activity go here!
  var timerName: String
}

// MARK: - WidgetLiveActivity

struct LoveDive_WidgetLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: TimerAttributes.self) { context in
      // Lock screen/banner UI goes here

      HStack {
        ZStack {
          Circle()
            .stroke(Color.darkBlue, lineWidth: 5)
            .rotationEffect(.init(degrees: -90))
            .padding(12)
          Circle()
            .trim(from: 0, to: context.state.progress)
            .stroke(Color.pacificBlue.gradient, style: StrokeStyle(
              lineWidth: 5,
              lineCap: .round))
            .rotationEffect(.init(degrees: -90))
            .padding(12)
        }
        Text("Breathe")
          .font(.callout)
          .padding(8)
        Text(timerInterval: context.state.endTime, countsDown: true)
          .multilineTextAlignment(.trailing)
          .monospacedDigit() // fixed width
          .font(.largeTitle)
          .fontDesign(.rounded)
          .bold()
          .padding(.trailing, 14)
      }
      .activitySystemActionForegroundColor(Color.black)
      .foregroundColor(.white)
      .frame(height: 65)
      .padding(14)
      .background(Color.black)

    } dynamicIsland: { context in
      DynamicIsland {
        // Expanded UI goes here.  Compose the expanded UI through
        // various regions, like leading/trailing/center/bottom
        DynamicIslandExpandedRegion(.leading) {
          HStack {
            Text("Breathe")
              .foregroundColor(.pacificBlue)
              .font(.callout)
              .fontDesign(.rounded)
              .padding(10)
          }
        }
        DynamicIslandExpandedRegion(.trailing) {
          ZStack {
            Circle()
              .stroke(Color.darkBlue, lineWidth: 5)
              .rotationEffect(.init(degrees: -90))
              .padding(8)
            Circle()
              .trim(from: 0, to: context.state.progress)
              .stroke(Color.pacificBlue.gradient, style: StrokeStyle(
                lineWidth: 5,
                lineCap: .round))
              .rotationEffect(.init(degrees: -90))
              .padding(8)
          }
          .frame(width: 50, height: 50)
        }
        DynamicIslandExpandedRegion(.bottom) {
          VStack {
            HStack {
              Spacer()
              Text(timerInterval: context.state.endTime, countsDown: true)
                .monospacedDigit()
                .font(.system(size: 60, weight: .bold))
                .fontDesign(.rounded)
              Spacer()
            }
            Spacer()
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
      } compactLeading: {
        HStack {
          ZStack {
            Circle()
              .stroke(Color.darkBlue, lineWidth: 3)
              .rotationEffect(.init(degrees: -90))
              .padding(2)
            Circle()
              .trim(from: 0, to: context.state.progress)
              .stroke(Color.pacificBlue.gradient, style: StrokeStyle(
                lineWidth: 3,
                lineCap: .round))
              .rotationEffect(.init(degrees: -90))
              .padding(2)
          }
          Spacer()
        }
        .frame(width: 40, height: 25)
      } compactTrailing: {
        Text(timerInterval: context.state.endTime, countsDown: true)
          .monospacedDigit()
          .font(.footnote)
          .fontDesign(.rounded)
          .multilineTextAlignment(.trailing)
          .frame(width: 40, height: 25)
      } minimal: {
        ZStack {
          Circle()
            .stroke(Color.darkBlue, lineWidth: 3)
            .rotationEffect(.init(degrees: -90))
            .padding(2)
          Circle()
            .trim(from: 0, to: context.state.progress)
            .stroke(Color.pacificBlue.gradient, style: StrokeStyle(
              lineWidth: 3,
              lineCap: .round))
            .rotationEffect(.init(degrees: -90))
            .padding(2)
        }
        .frame(width: 25, height: 25)
        .background(Color.black)
      }
      .widgetURL(URL(string: "http://www.apple.com"))
      .keylineTint(Color.pacificBlue)
    }
  }
}

// MARK: - WidgetLiveActivity_Previews

struct WidgetLiveActivity_Previews: PreviewProvider {
  static let attributes = TimerAttributes(timerName: "Me")
  static let contentState = TimerAttributes.ContentState(endTime: Date()...Date().addingTimeInterval(59 * 60), progress: 1)

  static var previews: some View {
    attributes
      .previewContext(contentState, viewKind: .dynamicIsland(.compact))
      .previewDisplayName("Island Compact")
    attributes
      .previewContext(contentState, viewKind: .dynamicIsland(.expanded))
      .previewDisplayName("Island Expanded")
    attributes
      .previewContext(contentState, viewKind: .dynamicIsland(.minimal))
      .previewDisplayName("Minimal")
    attributes
      .previewContext(contentState, viewKind: .content)
      .previewDisplayName("Notification")
  }
}
