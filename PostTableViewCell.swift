//
//  PostTableViewCell.swift
//  surplusapp
//
//  Created by Student on 4/12/17.
//  Copyright © 2017 Student. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var amountLabel: UILabel! //change to a visual representation of amount later
    @IBOutlet weak var locationHolder: UILabel!
    @IBOutlet weak var onTheWay: UILabel!
    @IBOutlet weak var onMyWayLabel: UILabel!
    @IBOutlet weak var onMyWayBut: UIButton!
    @IBOutlet weak var flagBut: UIButton!

    //var posted: Double
    var ref:FIRDatabaseReference!
    var ID:String!
    var omw:Bool!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        omw = false;
        ref = FIRDatabase.database().reference()
        
        loadattributes()
    }
    
    @IBAction func onMyWay(_ sender: Any) {
        onMyWayBut.setTitle("On My Way!", for: .normal)
        onMyWayBut.setImage(nil, for: .normal)
        
        //transactor to handle the on my way count
        omwtransact()

        let table = self.superview as? UITableView
        table?.reloadData()
        
    }
    
   /* @IBAction func onmywayBut(_ sender: UIButton, forEvent event: UIEvent) {
        onMyWayBut.setTitle("On My Way!", for: .normal)
        onMyWayBut.setImage(nil, for: .normal)
    }
 */
    
   /* @IBAction func flagButton(_ sender: UIButton, forEvent event: UIEvent) {
        flagBut.setImage(#imageLiteral(resourceName: "filledFlag"), for: .normal)
    }
 */
    //needs to use a similar framework as on my way, so users can only flag the post one time
    @IBAction func flagPost(_ sender: AnyObject) {
        flagBut.setImage(#imageLiteral(resourceName: "filledFlag"), for: .normal)
        
        flag()
        
        let table = self.superview as? UITableView
        table?.reloadData()
        
        
    }
    
    func loadattributes(){
        let user = (FIRAuth.auth()?.currentUser?.email)
        if user != nil{
            let userID = user?.replacingOccurrences(of:  ".", with: "")
            //)user?.trimmingCharacters(in: CharacterSet(charactersIn:".[]#$").inverted);
            //print(userID)
            //var alreadyclaimed = false;
            let userclaims = ref?.child("Users").child(userID!).child("Claims")
            let handle = userclaims?.observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.hasChild(self.ID!){
                    for (key, value) in snapshot.value as! NSDictionary{
                        if key as! String == self.ID{
                            if snapshot.value as! Bool == true{
                                self.onMyWayBut.setTitle("On My Way!", for: .normal)
                                self.onMyWayBut.setImage(nil, for: .normal)
                            }
                            else{
                                self.onMyWayBut.setTitle("", for: .normal)
                                self.onMyWayBut.setImage(UIImage(named: "onMyWay"), for: .normal)
                            }
                        }
                    }
                    
                }
            })
        }
        
                    
                    
    }
    
    func omwtransact(){
        
        //print(self.ID)
        
        let user = (FIRAuth.auth()?.currentUser?.email)
        if user != nil{
            let userID = user?.replacingOccurrences(of:  ".", with: "")
        //)user?.trimmingCharacters(in: CharacterSet(charactersIn:".[]#$").inverted);
            //print(userID)
            //var alreadyclaimed = false;
            let userclaims = ref?.child("Users").child(userID!).child("Claims")
            let handle = userclaims?.observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.hasChild(self.ID!){
                    
                    //TODO:
                    //Alexis: Do something visual indicating we can't click the "OMW" button more than once -- turn it a different color/ maybe a popup saying "are you sure you want to claim this? you can't undo it"
                    //self.onMyWayBut.setTitle("On My Way!", for: .normal)
                   // self.onMyWayBut.setImage(nil, for: .normal)
                    
                } else {
                        //add the child
                        self.ref?.child("Users").child(userID!).child("Claims").child(self.ID).setValue(true)
                    
                        let thispost:FIRDatabaseReference = (self.ref?.child("Posts").child(self.ID))!
                        
                        thispost.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
                            if var post = currentData.value as? [String : AnyObject]{
                                
                                var numclaimed = post["omw"] as? Int ?? 0
                                numclaimed += 1
                                
                                post["omw"] = numclaimed as AnyObject?
                                
                                currentData.value = post
                                //self.omw=true
                                return FIRTransactionResult.success(withValue: currentData)
                            }
                            return FIRTransactionResult.success(withValue: currentData)
                        }) { (error, committed, snapshot) in
                            if let error = error {
                                print(error.localizedDescription)
                            }
                        }

                }
            })
            
        }
    }
    
    func flag(){
        let user = (FIRAuth.auth()?.currentUser?.email)
        if user != nil{
            let userID = user?.replacingOccurrences(of:  ".", with: "")
            //)user?.trimmingCharacters(in: CharacterSet(charactersIn:".[]#$").inverted);
            //print(userID)
            //var alreadyclaimed = false;
            let userflags = ref?.child("Users").child(userID!).child("Flags")
            let handle = userflags?.observe(.value, with: { (snapshot) in
                if snapshot.hasChild(self.ID!){
                    
                    //TODO:
                    //Alexis: flag visuals - maybe turn the flag red?
                    
                    //self.flagBut.setImage(#imageLiteral(resourceName: "filledFlag"), for: .normal)
                    
                } else {
                    //add the child
                    self.ref?.child("Users").child(userID!).child("Flags").child(self.ID).setValue(true)
                    
                    let thispost:FIRDatabaseReference = (self.ref?.child("Posts").child(self.ID))!
                    
                    thispost.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
                        if var post = currentData.value as? [String : AnyObject]{
                            
                            var numclaimed = post["flags"] as? Int ?? 0
                            numclaimed += 1
                            
                            post["flags"] = numclaimed as AnyObject?
                            
                            currentData.value = post
                            //self.omw=true
                            return FIRTransactionResult.success(withValue: currentData)
                        }
                        return FIRTransactionResult.success(withValue: currentData)
                    }) { (error, committed, snapshot) in
                        if let error = error {
                            print(error.localizedDescription)
                        }
                    }
                    
                }
            })
            
        }
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
