//
//  SwiftUIView.swift
//  
//
//  Created by tester on 6/28/22.
//

import SwiftUI

public struct InvisibleView: View {
    public var body: some View {
        Rectangle()
            .frame(width: 0, height: 0)
    }
}
