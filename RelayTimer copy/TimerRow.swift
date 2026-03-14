//
//  TimerRow.swift
//  RelayTimer
//
//  Created by 福田光一郎 on 2026/03/12.
//

import SwiftUI

struct TimerRow: View {
    
    var name: String
    var time: String
    
    var body: some View {
            HStack {
                
                Circle()
                    .stroke(Color.black, lineWidth: 2)
                    .frame(width: 60, height: 60)
                
                VStack(alignment: .leading) {
                    Text(name)
                        .font(.title2)
                    
                    Divider()
                }
                
                Spacer()
                
                Text(time)
                    .font(.title2)
                
                Image(systemName: "pencil")
            }
            .padding(.horizontal)
        }
       
}


#Preview {
    TimerRow(name: "調理", time: "5:00")
}
