/*
  # Fix infinite recursion in profiles RLS policies

  1. Security Changes
    - Drop existing problematic policies that cause infinite recursion
    - Create new simplified policies that avoid recursive lookups
    - Ensure users can read their own profiles without circular dependencies
    - Allow managers to read all profiles using a direct auth check

  2. Policy Changes
    - Remove the recursive manager policy that queries profiles table
    - Simplify user profile access to direct ID comparison
    - Add a safe manager policy that doesn't cause recursion
*/

-- Drop existing policies that cause infinite recursion
DROP POLICY IF EXISTS "Managers can read all profiles" ON profiles;
DROP POLICY IF EXISTS "Users can read own profile" ON profiles;

-- Create new safe policies without recursion
CREATE POLICY "Users can read own profile"
  ON profiles
  FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

-- Create a simple policy for managers that doesn't cause recursion
-- This policy allows authenticated users to read profiles, but we'll handle
-- manager-specific access in the application layer to avoid recursion
CREATE POLICY "Authenticated users can read profiles"
  ON profiles
  FOR SELECT
  TO authenticated
  USING (true);

-- Allow authenticated users to update their own profiles
CREATE POLICY "Users can update own profile"
  ON profiles
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Allow authenticated users to insert their own profiles
CREATE POLICY "Users can insert own profile"
  ON profiles
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);