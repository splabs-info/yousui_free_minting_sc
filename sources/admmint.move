module yousuinfts::admmint {

    use yousuinfts::nft::{Self};
    use sui::tx_context::{Self, TxContext};
    use std::string::{utf8, bytes, String};
    use sui::object::{Self, UID};
    use std::vector;
    use sui::transfer;


    // errors
   
    const ENotAuthorized: u64 = 1; 
    const ENotWhitelist: u64 = 2;
    const EWhitelistExist: u64 = 3;
    const EWhitelistNotExist: u64 = 4;
    const EMaxMintPerAddress: u64 = 5;
    const EMaxMint: u64 = 6;
    const ENotActive: u64 = 7;



    
    struct Minted {
        owner: address,
        count: u64,
    }

    struct AdmMint has key {
        id: UID,
        number: u64,
        max_mint: u64,
        mint_per_time: u64,
        whitelist: vector<address>,
        randoms: vector<u8>,
        creator: address,
        active: bool,
        image_og: String,
        image_tier1: String,
        image_tier2: String,
        image_tier3: String,
        image_tier4: String,
        image_tier5: String,
        image_pfp1: String,
        image_pfp2: String,
        image_pfp3: String,
        image_pfp4: String,
    }



    public entry fun create_mint(mint_per_time: u64, max_mint: u64, ctx: &mut TxContext) {
        
        assert!(@0xbb47b7e40f8e1f7f4cd6f15bdeceaccb2afcc103396fc70456dbc2b63f647679 == tx_context::sender(ctx), ENotAuthorized);
        let newadmmint = AdmMint {
            id: object::new(ctx),
            number: 0,
            mint_per_time: mint_per_time,
            max_mint: max_mint,
            whitelist: vector::empty<address>(),
            randoms:vector::empty<u8>(),
            active:true,
       
            image_og: utf8(b"https://files.yousui.io/mint/YouSUI_NFT_OGROLE.png"),
            image_tier1: utf8(b"https://files.yousui.io/mint/YouSUI_NFT_TIER1.png"),
            image_tier2: utf8(b"https://files.yousui.io/mint/YouSUI_NFT_TIER2.png"),
            image_tier3: utf8(b"https://files.yousui.io/mint/YouSUI_NFT_TIER3.png"),
            image_tier4: utf8(b"https://files.yousui.io/mint/YouSUI_NFT_TIER4.png"),
            image_tier5: utf8(b"https://files.yousui.io/mint/YouSUI_NFT_TIER5.png"),
            image_pfp1: utf8(b"https://files.yousui.io/mint/YouSUI_NFT_PFP1.png"),
            image_pfp2: utf8(b"https://files.yousui.io/mint/YouSUI_NFT_PFP2.png"),
            image_pfp3: utf8(b"https://files.yousui.io/mint/YouSUI_NFT_PFP3.png"),
            image_pfp4: utf8(b"https://files.yousui.io/mint/YouSUI_NFT_PFP4.png"),
            creator: tx_context::sender(ctx),
        };
        transfer::share_object(newadmmint);
    }

    public entry fun update_active(new: bool, newadmmint: &mut AdmMint, ctx: &mut TxContext){ 
        assert!(newadmmint.creator == tx_context::sender(ctx), ENotAuthorized);
        newadmmint.active = new;
    }


    public entry fun update_maxmint(new: u64, newadmmint: &mut AdmMint, ctx: &mut TxContext){ 
        assert!(newadmmint.creator == tx_context::sender(ctx), ENotAuthorized);
        newadmmint.max_mint = new;
    }

    public entry fun update_maxmintpertime(new: u64, newadmmint: &mut AdmMint, ctx: &mut TxContext){ 
        assert!(newadmmint.creator == tx_context::sender(ctx), ENotAuthorized);
        newadmmint.mint_per_time = new;
    }

    public entry fun updaterandomlist(list: vector<u8>, newadmmint: &mut AdmMint, ctx: &mut TxContext){
        assert!(newadmmint.creator == tx_context::sender(ctx), ENotAuthorized);
        newadmmint.randoms = list;
    }



    public entry fun add_address_into_whitelist(newadmmint: &mut AdmMint, 
     addr_whitelist: address,
     ctx: &mut TxContext,
    ) {
        assert!(newadmmint.creator == tx_context::sender(ctx), ENotAuthorized);
        assert!(!vector::contains(&newadmmint.whitelist, &addr_whitelist), EWhitelistExist);
        vector::push_back(&mut newadmmint.whitelist,addr_whitelist);      
    }

    public entry fun remove_address_whitelist(newadmmint: &mut AdmMint, 
     addr_whitelist: address,
     ctx: &mut TxContext,
    ) {
        assert!(newadmmint.creator == tx_context::sender(ctx), ENotAuthorized);
       // assert!(vector::contains(&mint.whitelist, &addr_whitelist), EWHITELIST_EXIST);
        let (check,i) = vector::index_of(&newadmmint.whitelist,&addr_whitelist);
        assert!(check, EWhitelistNotExist);
        vector::remove(&mut newadmmint.whitelist,i);  
    }

     public entry fun reset_whitelist(newadmmint: &mut AdmMint, 
     ctx: &mut TxContext,
    ) {
        assert!(newadmmint.creator == tx_context::sender(ctx), ENotAuthorized);
        newadmmint.whitelist = vector::empty();
    }

    public entry fun update_image(
        newadmmint: &mut AdmMint,
        type: u64,
        index: u64,
        image_url: String,
        ctx: &mut TxContext
    ) {
        assert!(newadmmint.creator == tx_context::sender(ctx), ENotAuthorized);
        if(type == 0)
        {
             newadmmint.image_og = image_url
        };
        if(type == 1)
        {
             newadmmint.image_tier1 = image_url
        };
        if(type == 2)
        {
             newadmmint.image_tier2 = image_url
        };
        if(type == 3)
        {
             newadmmint.image_tier3 = image_url
        };
        if(type == 4)
        {
             newadmmint.image_tier4 = image_url
        };
        if(type == 5)
        {
             newadmmint.image_tier5 = image_url
        };
        if(type == 6)
        {
            if(index == 1 )
            newadmmint.image_pfp1 = image_url;
            if(index == 2 )
            newadmmint.image_pfp2 = image_url;
            if(index == 3 )
            newadmmint.image_pfp3 = image_url;
            if(index == 4 )
            newadmmint.image_pfp4 = image_url;
        };
        
    }


    fun get_type(number: u8): vector<u8>{

        let type: vector<u8>;
        type = b"pfp";
        if(number == 0) {
            type = b"og";
        };
        if(number == 1) {
            type = b"1";
        };
        if(number == 2) {
            type = b"2";
        };
        if(number == 3) {
            type = b"3";
        };
        if(number == 4) {
            type = b"4";
        };
        if(number == 5) {
            type = b"5";
        };
        type

    }

    fun get_image_url(type:vector<u8>, newadmmint: &mut AdmMint):vector<u8> {

        let image_url: vector<u8>;
        image_url = b"";

        if(type == b"5") {
            image_url = *bytes(&newadmmint.image_tier5);
        };

        if(type == b"4") {
            image_url = *bytes(&newadmmint.image_tier4);
        };

        if(type == b"3") {
            image_url = *bytes(&newadmmint.image_tier3);
        };

        if(type == b"2") {
            image_url = *bytes(&newadmmint.image_tier2);
        };

        if(type == b"1") {
            image_url = *bytes(&newadmmint.image_tier1);
        };

         if(type == b"og"){
            image_url = *bytes(&newadmmint.image_og);
        };

        if(type == b"pfp"){
   
            if(newadmmint.number %4 == 0)
            image_url = *bytes(&newadmmint.image_pfp4);
            if(newadmmint.number %4 == 1)
            image_url = *bytes(&newadmmint.image_pfp1);
            if(newadmmint.number %4 == 2)
            image_url = *bytes(&newadmmint.image_pfp2);
            if(newadmmint.number %4 == 3)
            image_url = *bytes(&newadmmint.image_pfp3);
        };

        image_url
    }


    public entry fun mint(newadmmint: &mut AdmMint, nftinfo: &mut nft::Infomation  ,ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        assert!(newadmmint.active == true, ENotActive);
        // check whitelist if is_whitelist
        assert!(
                vector::contains(&newadmmint.whitelist, &sender),
                ENotWhitelist
            );
        //
        let i = 0;
        if(newadmmint.mint_per_time >0) {
            while( i < newadmmint.mint_per_time ) {
                
                i = i+1;
                assert!(newadmmint.number < newadmmint.max_mint, EMaxMint);
                let index_type = vector::pop_back(&mut newadmmint.randoms) - 48;
                let type: vector<u8>;
                let image_url: vector<u8>;
                type = get_type(index_type);
                image_url = get_image_url(type,newadmmint);
                nft::mint(type,image_url,nftinfo,ctx);
                newadmmint.number = newadmmint.number+1;
           
            };
        } else {
                assert!(newadmmint.number < newadmmint.max_mint, EMaxMint);
                let index_type = vector::pop_back(&mut newadmmint.randoms) - 48;
                let type: vector<u8>;
                type = get_type(index_type);
                let image_url: vector<u8>;
                image_url = get_image_url(type,newadmmint);
                nft::mint(type,image_url,nftinfo,ctx);
                newadmmint.number = newadmmint.number+1;
     
        };

    }
}