/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.randomlogic.perftest.product.dashboard;

import java.io.Serializable;

/**
 *
 * @author Paul G. Allen <pgallen@gmail.com>
 */
public class DebugLogger implements Serializable
{
    private static final long serialVersionUID = 1L;
    
    public static void debug (boolean enable, String message)
    {
        if (enable)
        {
            System.out.println (message);
        }
    }
}
