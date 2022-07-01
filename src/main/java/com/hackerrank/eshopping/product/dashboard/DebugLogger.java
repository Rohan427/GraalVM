/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.hackerrank.eshopping.product.dashboard;

/**
 *
 * @author Paul G. Allen <pgallen@gmail.com>
 */
public class DebugLogger
{
    public static void debug (boolean enable, String message)
    {
        if (enable)
        {
            System.out.println (message);
        }
    }
}
