//
//  SupportedProject.swift
//  CCLions
//
//  Created by 李冬 on 6/14/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import Foundation

class SupportedProject: Project {
    var amount: Int!
    var application: String!
    
    init(
        id: Int,
        title: String,
        time: String,
        launcher_id: Int,
        favorite: Int,
        cover_image: String,
        details_page: String,
        project_type: Int,
        fundraising_amount: Int!,
        has_raised_amount: Int!,
        withdraw_amount: Int!,
        apply_for_other: Int,
        aided_person_id_num: String,
        aided_person_id_card_photo: String,
        left_time: Int,
        sponsorship_company_id: Int,
        create_time: String,
        name: String,
        header: String,
        amount: Int,
        application: String
        ) {
        super.init(
            id: id,
            title: title,
            time: title,
            launcher_id:
            launcher_id,
            favorite: favorite,
            cover_image: cover_image,
            details_page: details_page,
            project_type: project_type,
            fundraising_amount: fundraising_amount,
            has_raised_amount: has_raised_amount,
            withdraw_amount: withdraw_amount,
            apply_for_other: apply_for_other,
            aided_person_id_num: aided_person_id_num,
            aided_person_id_card_photo: aided_person_id_card_photo,
            left_time: left_time,
            sponsorship_company_id: sponsorship_company_id,
            create_time: create_time,
            name: name,
            header: header)
        
        self.amount = amount
        self.application = application
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}