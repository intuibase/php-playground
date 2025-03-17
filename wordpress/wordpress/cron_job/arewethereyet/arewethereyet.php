<?php
/*
Plugin Name: arewethereyet
*/
        add_action( 'arewethereyet_hook', 'arewethereyet_func' );

        function arewethereyet_func() {
                $curl = curl_init(get_site_url().'/wp-content/uploads/2018/04/arewethereyet.jpg');
                curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);
                $result = curl_exec($curl);
                curl_close($curl);

        }
?>
