//
//  TimerListView.swift
//  RelayTimer
//
//  Created by 福田光一郎 on 2026/03/04.
//

import SwiftUI

struct TimerListView: View {
    @State var TimerSetName : String = "朝の支度"
    var body: some View {
        VStack (spacing: 30){
            HStack{
                Text(TimerSetName)
                    .font(.system(size: 50))
                
                Button{
                    
                }label: {
                    NavigationLink(destination: TimerView()) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(Color(.red))
                    }
                }
            }
            HStack{
                Text(TimerSetName)
                    .font(.system(size: 50))
                
                Button{
                    
                }label: {
                    NavigationLink(destination: TimerView()) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(Color(.red))
                    }
                }
            }
            Spacer()
            HStack{
                Spacer()
                Button{
                    
                }label: {
                    Image(systemName: "plus")
                        .frame(width: 100, height: 100)
                        .foregroundStyle(Color(.black))
                        .glassEffect()
                }
            }
        }
        .navigationTitle("タイマーセット一覧")
        .navigationBarTitleDisplayMode(.large)
    }
}


#Preview {
    NavigationStack {
        TimerListView()
    }
}
